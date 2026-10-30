"""
Erreur d'un modèle de géoréférencement par rapport à la BD Ortho.

Usage :
    python comparaison.py <pts_cliche> <pts_bdortho> <pts_reproj>

Exemple (SuperGlue) :
    python comparaison.py  XXX.ptsspg  XXX_BDOrtho.ptsspg  XXX_ptsreproj_aff.modelespg

  pts_cliche  : points dans l'image du cliché (x y), un point par ligne
  pts_bdortho : mêmes points dans la BD Ortho (X Y en L93)  -> la "vérité"
  pts_reproj  : mêmes points placés par le modèle (X Y en L93) -> la "prédiction"

Les 3 fichiers doivent avoir le même nombre de lignes, dans le même ordre.
"""

import os
import sys
import numpy as np
import matplotlib.pyplot as plt

if len(sys.argv) != 4:
    sys.exit(__doc__)

f_cliche, f_ref, f_pred = sys.argv[1:4]
cliche = np.loadtxt(f_cliche)
ref = np.loadtxt(f_ref)
pred = np.loadtxt(f_pred)



if not (len(cliche) == len(ref) == len(pred)):
    sys.exit(f"Nombres de points différents : {len(cliche)}, {len(ref)}, {len(pred)}")

VMAX_NORME = 120.
VMAX_DXDY = 100.

# 1) Résidus : prédiction - vérité, en mètres
dxy = pred - ref
err = np.hypot(dxy[:, 0], dxy[:, 1])


# 3) Carte : un vecteur d'erreur par point, positionné dans l'image du cliché
fig, ax = plt.subplots(figsize=(7, 6))
q = ax.quiver(cliche[:, 0], cliche[:, 1], dxy[:, 0], dxy[:, 1], err,
              angles="xy", cmap="magma", clim=(0, VMAX_NORME))
ax.invert_yaxis()
ax.set_aspect("equal")
ax.set_xlabel("x cliché (px)")
ax.set_ylabel("y cliché (px)")
ax.set_title(f"Erreur modèle - BD Ortho (médiane {np.median(err):.1f} m)")
plt.colorbar(q, label="erreur (m)")
sortie = os.path.basename(f_pred) + ".residus.png"   # dans le dossier courant
plt.savefig(sortie, dpi=130, bbox_inches="tight")
print(f"Carte enregistrée   : {sortie}")
 
# 4) Carte d'erreur interpolée (spline plaque mince, lissée)
from scipy.interpolate import RBFInterpolator
from scipy.spatial import Delaunay
 
LISSAGE = 2.0 * len(err)          # plus grand = carte plus lisse (choix empirique)
 
rbf = RBFInterpolator(cliche, err, kernel="thin_plate_spline", smoothing=LISSAGE)
gx, gy = np.meshgrid(np.linspace(cliche[:, 0].min(), cliche[:, 0].max(), 150),
                     np.linspace(cliche[:, 1].min(), cliche[:, 1].max(), 150))
grille = np.c_[gx.ravel(), gy.ravel()]
z = np.clip(rbf(grille), 0, None).reshape(gx.shape)           # pas d'erreur négative
hors_points = Delaunay(cliche).find_simplex(grille) < 0       # zones sans points : on masque
z = np.ma.masked_where(hors_points.reshape(gx.shape), z)
 
fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(z, extent=[gx.min(), gx.max(), gy.max(), gy.min()], cmap="magma",
               vmin=0, vmax=VMAX_NORME)
ax.scatter(cliche[:, 0], cliche[:, 1], c="w", s=4)
ax.set_xlabel("x cliché (px)")
ax.set_ylabel("y cliché (px)")
ax.set_title("Erreur interpolée (zones sans points masquées)")
plt.colorbar(im, label="erreur lissée (m)")
sortie2 = os.path.basename(f_pred) + ".interp.png"
plt.savefig(sortie2, dpi=130, bbox_inches="tight")
print(f"Carte interpolée    : {sortie2}")
 
# 5) Variante dx / dy : on interpole chaque composante de l'erreur séparément,
#    puis on recalcule la norme. Garde la direction de l'erreur.
rbf_dx = RBFInterpolator(cliche, dxy[:, 0], kernel="thin_plate_spline", smoothing=LISSAGE)
rbf_dy = RBFInterpolator(cliche, dxy[:, 1], kernel="thin_plate_spline", smoothing=LISSAGE)
zx = rbf_dx(grille).reshape(gx.shape)
zy = rbf_dy(grille).reshape(gx.shape)
znorme = np.ma.masked_where(hors_points.reshape(gx.shape), np.hypot(zx, zy))
zx = np.ma.masked_where(hors_points.reshape(gx.shape), zx)
zy = np.ma.masked_where(hors_points.reshape(gx.shape), zy)
 
fig, axs = plt.subplots(1, 3, figsize=(16, 5))
etendue = [gx.min(), gx.max(), gy.max(), gy.min()]
# échelle symétrique autour de 0 pour dx et dy (fixée par VMAX_DXDY si fourni)
vmax_c = VMAX_DXDY or max(np.abs(zx.compressed()).max(), np.abs(zy.compressed()).max())
for ax, z_, titre, cmap, vmin, vmax in [
        (axs[0], zx, "dx interpolé (m)", "RdBu_r", -vmax_c, vmax_c),
        (axs[1], zy, "dy interpolé (m)", "RdBu_r", -vmax_c, vmax_c),
        (axs[2], znorme, "norme recalculée (m)", "magma", 0, VMAX_NORME)]:
    im = ax.imshow(z_, extent=etendue, cmap=cmap, vmin=vmin, vmax=vmax)
    ax.scatter(cliche[:, 0], cliche[:, 1], c="k", s=3)
    ax.set_title(titre)
    ax.set_xlabel("x cliché (px)")
    plt.colorbar(im, ax=ax)
axs[0].set_ylabel("y cliché (px)")
sortie3 = os.path.basename(f_pred) + ".interp_dxdy.png"
plt.savefig(sortie3, dpi=130, bbox_inches="tight")
print(f"Carte dx/dy         : {sortie3}")
 
