import sys
import os

from tri_spatial import regrouper, charger_depuis_base

if len(sys.argv) != 4:
    print(f"Usage : python {sys.argv[0]} base.db seuil_metres dossier_traitement")
    quit()

database = sys.argv[1]
seuil = float(sys.argv[2])
dossier_traitement = sys.argv[3]

for chantier in sorted(os.listdir(dossier_traitement)):
    chemin = os.path.join(dossier_traitement, chantier)
    if not os.path.isdir(chemin):
        continue

    urls = [f[:-4] for f in os.listdir(chemin) if f.endswith(".tif")]
    if len(urls) < 2:
        continue

    lst_cliches = charger_depuis_base(database, urls)
    groupes = regrouper(lst_cliches, seuil)

    if len(groupes) > 1:
        print(f"ALERTE : {chantier} contient {len(groupes)} zones distinctes (> {seuil} m)")