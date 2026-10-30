if [ $# -lt 2 ]; then
    echo "Usage : $0 liste.txt nom_chantier [seuil]"
    exit 1
fi

liste="$1"
nom_chantier="$2"
seuil="${3:-500}"

cdt_bord=true
nettoyage=true
methode="tout"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

dossier_traitement="$ROOT_DIR/Echantillon_jp2_mars2025"
bdd="$ROOT_DIR/base.db"

python3 "$ROOT_DIR/test_presence_bdd.py" "$bdd" "$liste"

mapping="$ROOT_DIR/affectation_${nom_chantier}.txt"
> "$mapping"
while read -r nom_image; do
    [ -z "$nom_image" ] && continue
    echo "$nom_image $nom_chantier" >> "$mapping"
done < pva_present.txt

bash "$ROOT_DIR/download.sh" \
    --input pva_present.txt \
    --output "$dossier_traitement" \
    --chantiers "$mapping"

python3 "$ROOT_DIR/verif_chantier.py" "$bdd" "$seuil" "$dossier_traitement"

bash "$ROOT_DIR/bash_processus.sh" "$bdd" "$dossier_traitement" "$cdt_bord"

liste_ok="$dossier_traitement/liste_chantiers_ok.txt"
if [ ! -s "$liste_ok" ]; then
    echo "Aucun chantier avec BDOrtho valide, arret."
    exit 1
fi

for chantier in $(cat "$liste_ok"); do
    echo "Traitement de ${chantier} "
    bash "$ROOT_DIR/bash_traitement_serie2_export_points_gdalpam_affonly.sh" "${chantier}" "$dossier_traitement" "$methode"
done

bash "$ROOT_DIR/bash_export.sh" "$dossier_traitement" "$methode"

if [ "$nettoyage" = true ]; then
    bash "$ROOT_DIR/cleanup.sh" "$dossier_traitement"
fi