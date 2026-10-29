if [ -z "$1" ]; then
    echo "Usage : $0 <dossier_de_traitement>"
    exit 1
fi
dossier_traitement="$1"
 
cd "$dossier_traitement"

for chantier in `cat liste_chantiers_ok.txt`; do
    echo "Suppression de ${chantier}"
    rm -rf "${chantier}"
done
 
for chantier in `cat liste_chantiers_kc.txt`; do
    echo "Suppression de ${chantier}"
    rm -rf "${chantier}"
done