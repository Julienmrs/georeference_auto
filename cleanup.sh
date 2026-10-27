if [ -z "$1" ]; then
    echo "Usage : $0 <dossier_de_traitement>"
    exit 1
fi
dossier_traitement="$1"
 
cd "$dossier_traitement"
cd "Echantillon_jp2_mars2025"

for chantier in `cat liste_chantiers_ok.txt`; do
    echo "Suppression de ${chantier}"
    rm -rf "${chantier}"
done
