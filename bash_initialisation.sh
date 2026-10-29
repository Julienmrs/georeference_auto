if [ -z "$1" ]; then
    echo "Erreur : Vous devez spécifier le chemin de la base de données."
    echo "Usage : \$0 <chemin_vers_la_bdd.db> <cdt_bord:true|false>"
    exit 1
fi

bdd="$1"
cdt_bord="${2:-true}"
# Parcours des chantiers et calcul l'emprise de chaque cliché, puis export des coordonnées terrain et image afin de télécharger la bd ortho
for cliche in `cat liste_cliches.txt`; do
    nomcliche=${cliche%.*} ;
    echo ${nomcliche} ;
    extension=${cliche##*.} ;
    python3  $ROOT_DIR/OutilsLB/Recherche_Geojason_bdd.py $bdd ${nomcliche}.${extension} ${nomcliche}.geojson ;
    ogr2ogr -t_srs EPSG:2154 ${nomcliche}.L93.geojson ${nomcliche}.geojson ;
    python3 $ROOT_DIR/OutilsLB/GeoJson2ExportCoordTerrain.py ${nomcliche}.L93.geojson ${nomcliche}.L93.coordL93.txt ;
    gdal_translate ${nomcliche}.${extension} ${nomcliche}2.tif ;
    if [ "$cdt_bord" = true ]; then
        $ROOT_DIR/OutilsLB/Coherence.LINUX DetecteBord  --cliche ${nomcliche}2.${extension} --output:emprise:8 coord_img_sans_bord.txt
        statut=$?
    else
        statut=1
    fi
    if [ $statut -eq 0 ] && [ -s coord_img_sans_bord.txt ]; then
            python3 $ROOT_DIR/OutilsLB/ExportCoordIm_multi.py coord_img_sans_bord.txt ${nomcliche}.coordim ;
        else
            python3 $ROOT_DIR/OutilsLB/ExportCoordIm_multi.py ${nomcliche}.${extension} ${nomcliche}.coordim ;
    fi
    rm ${nomcliche}2.tif
    for j in 0 1 2 3 ; do
	python3 $ROOT_DIR/OutilsLB/CalculTransfo.py ${nomcliche}.L93.coordL93.txt ${nomcliche}.coordim_rot${j} ${nomcliche}.tfw_rot${j} ;
    done ;
done 
