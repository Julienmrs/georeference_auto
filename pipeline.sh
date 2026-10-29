#!/bin/bash

#----------------Parametres--------------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fichier_a_traiter="$ROOT_DIR/list_dl.txt"
dossier_traitement="$ROOT_DIR/Echantillon_jp2_mars2025"
bdd="$ROOT_DIR/base.db"

# true regroupement geographique au telechargement, cliches proches dans un meme dossier, nom du premier dans la liste
# false pour revenir a un traitement cliche par cliche
regroupement_actif=true
seuil=5000 # en metres

cdt_bord=true  # true pour detecter les bords de cliche et ne pas prendre les points de bord, false pour ne pas detecter les bords

nettoyage=true # true pour supprimer les dossiers de traitement apres export, false pour garder les dossiers de traitement

#---------------Chaine--------------------------------------
echo "Root dir: $ROOT_DIR"
echo "Fichier a traiter: $fichier_a_traiter"

#---------------Verification des cliches--------------------
python3 "$ROOT_DIR/test_presence_bdd.py" \
    "$bdd" \
    "$fichier_a_traiter"

#---------------Telechargement des cliches------------------
chantiers_args=()
if [ "$regroupement_actif" = true ]; then
    python3 "$ROOT_DIR/tri_spatial.py" "$bdd" "$seuil" "$ROOT_DIR/pva_present.txt" --dossiers > "$ROOT_DIR/affectation_dossiers.txt"
    chantiers_args=(--chantiers "$ROOT_DIR/affectation_dossiers.txt")
fi

bash "$ROOT_DIR/download.sh" \
    --input "$ROOT_DIR/pva_present.txt" \
    --output "$dossier_traitement" \
    "${chantiers_args[@]}"

python3 "$ROOT_DIR/verif_chantier.py" "$bdd" "$seuil" "$dossier_traitement"

#-----------------PreTraitement des cliches-------------------
bash "$ROOT_DIR/bash_processus.sh" "$bdd" "$dossier_traitement" "$cdt_bord"

liste_ok="$dossier_traitement/liste_chantiers_ok.txt"
if [ ! -s "$liste_ok" ]; then
    echo "Aucun chantier avec BDOrtho valide, arret."
    exit 1
fi

#-----------------Traitement des cliches-------------------
for chantier in $(cat "$liste_ok"); do
    echo "Traitement de ${chantier} "
    bash "$ROOT_DIR/bash_traitement_serie2_export_points_gdalpam_affonly.sh" "${chantier}"
done

bash "$ROOT_DIR/bash_export.sh" "$dossier_traitement"

###-----------------Version 5m-------------------
# bash "$ROOT_DIR/bash_traitement_serie2_export_points_gdalpam_affonly_5m.sh"
# bash "$ROOT_DIR/bash_export_5m.sh"

#-----------------Nettoyage-----------------
if [ "$nettoyage" = true ]; then
    bash "$ROOT_DIR/cleanup.sh" "$dossier_traitement"
fi
