    usage() {
    echo "Usage : $0 --input <fichier> --output <dossier>"
    exit 1
}

# Lecture des arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --input)
            fichier_a_dl="$2"
            shift 2
            ;;
        --output)
            dossier_de_dl="$2"
            shift 2
            ;;
        *)
            echo "Argument inconnu : $1"
            usage
            ;;
    esac
done

# Vérification des arguments
if [[ -z "$fichier_a_dl" || -z "$dossier_de_dl" ]]; then
    usage
fi

if [[ ! -f "$fichier_a_dl" ]]; then
    echo "Erreur : fichier introuvable : $fichier_a_dl"
    exit 1
fi

timestart=$SECONDS

mkdir -p "$dossier_de_dl"
echo -n "" > "${dossier_de_dl}/echec.txt"

while IFS= read -r nom_image; do
    # Ignore les lignes vides
    [[ -z "$nom_image" ]] && continue

    dossier="${dossier_de_dl}/${nom_image}"
    mkdir -p "$dossier"

    mission="${nom_image#*__C}"
    mission="${mission%%_*}"

    url="https://data.geopf.fr/telechargement/download/pva/${mission}/${nom_image}.tif"

    echo "Téléchargement : $nom_image"

    if wget -q --show-progress \
        --tries=5 \
        --timeout=60 \
        --waitretry=10 \
        --retry-on-http-error=502,503,504 \
        -O "${dossier}/${nom_image}.tif" \
        "$url"
    then
        echo "  -> OK"
    else
        echo "  -> ÉCHEC"
        echo "$nom_image" >> "${dossier_de_dl}/echec.txt"
    fi

done < "$fichier_a_dl"

echo "Temps total : $(( SECONDS - timestart )) secondes"
