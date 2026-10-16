# start=$(date +%s)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fichier_a_traiter="$ROOT_DIR/list_dl.txt"
dossier_traitement="$ROOT_DIR/Echantillon_jp2_mars2025"
bdd="$ROOT_DIR/index_pva_spatial.db"

echo "Root dir: $ROOT_DIR"
echo "Fichier à traiter: $fichier_a_traiter"

python3 "$ROOT_DIR/test_presence_bdd.py" \
    "$bdd" \
    "$fichier_a_traiter"

bash "$ROOT_DIR/download.sh" \
    --input "$ROOT_DIR/pva_present.txt" \
    --output "$dossier_traitement"
# end=$(date +%s)
echo "Temps dl : $((end - start)) s" >>"$ROOT_DIR/temps_ecoule.txt"

# start=$(date +%s)

bash "$ROOT_DIR/bash_processus.sh" "$bdd"

liste_ok="$dossier_traitement/liste_chantiers_ok.txt"
if [ ! -s "$liste_ok" ]; then
    echo "Aucun chantier avec BDOrtho valide, arret."
    exit 1
fi

# end=$(date +%s)
echo "Temps meta + bdd : $((end - start)) s" >>"$ROOT_DIR/temps_ecoule.txt"

# start=$(date +%s)
for chantier in $(cat "$liste_ok"); do
    echo "Traitement de ${chantier} "
    bash "$ROOT_DIR/bash_traitement_serie2_export_points_gdalpam_affonly.sh" "${chantier}"
done

# end=$(date +%s)
# echo "Temps écoulé : $((end - start)) s" >>"$ROOT_DIR/temps_ecoule.txt"
echo "$((end - start))" >"$ROOT_DIR/temps_ecoule.txt"

bash "$ROOT_DIR/bash_export.sh"


### Version 5m
# bash "$ROOT_DIR/bash_traitement_serie2_export_points_gdalpam_affonly_5m.sh"
# bash "$ROOT_DIR/bash_export_5m.sh"

