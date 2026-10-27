usage() {
    echo "Usage : $0 --input <fichier> --output <dossier> [--chantiers <fichier_mapping>]"
    exit 1
}

fichier_chantiers=""

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
        --chantiers)
            fichier_chantiers="$2"
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

declare -A dossier_par_image
if [[ -n "$fichier_chantiers" ]]; then
    while read -r nom_image nom_dossier; do
        [[ -z "$nom_image" ]] && continue
        dossier_par_image["$nom_image"]="$nom_dossier"
    done < "$fichier_chantiers"
fi

timestart=$SECONDS

mkdir -p "$dossier_de_dl"

while IFS= read -r nom_image; do
    # Ignore les lignes vides
    [[ -z "$nom_image" ]] && continue

    sous_dossier="${dossier_par_image[$nom_image]:-$nom_image}"
    dossier="${dossier_de_dl}/${sous_dossier}"
    mkdir -p "$dossier"

    mission="${nom_image#*__C}"
    mission="${mission%%_*}"

    url="https://data.geopf.fr/telechargement/download/pva/${mission}/${nom_image}.tif"

    echo "Téléchargement : $nom_image -> ${sous_dossier}"

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
        echo "$nom_image" >> "./echec.txt"
    fi

done < "$fichier_a_dl"

echo "Temps total : $(( SECONDS - timestart )) secondes"
