
find . -type d -print0 | while IFS= read -r -d '' dir; do

    if [ ! -f "$dir/BDOrtho.tif" ] && [ -f "$dir/bash_download_gdal.sh" ]; then
        echo "BDOrtho.tif absent dans : $dir"
        echo "Lancement de bash_download_gdal.sh..."

        (
            cd "$dir" || exit 1
            bash bash_download_gdal.sh
        )
    fi
    
done