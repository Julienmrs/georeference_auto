SOURCE="Echantillon_"
DEST="Echantillon_images"

mkdir -p "$DEST"

find "$SOURCE" -type f \( -iname "*.tif" -o -iname "*.jp2" \) -print0 |
while IFS= read -r -d '' file; do

    filename=$(basename "$file")
    name="${filename%.*}"

    image_dir="$DEST/$name"
    mkdir -p "$image_dir"

    cp "$file" "$image_dir/"
    echo "$filename -> $image_dir/"

done


