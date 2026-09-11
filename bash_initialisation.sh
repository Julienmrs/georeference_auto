#Il faut au prealable avoir cree la liste des cliches (chemin complet)

for cliche in `cat liste_cliches.txt`; do
    nomcliche=${cliche%.*} ;
    echo ${nomcliche} ;
    extension=${cliche##*.} ;
    ##ligne originale on parcourt les geojson pour trouver le bon a chaque lancement
    # python3 $ROOT_DIR/OutilsLB/Recherche_Geojason.py $ROOT_DIR/photos-aeriennes-ign-master/data/pva ${nomcliche} ;
    ### Nvelle ligne : on interroge une bdd  crée pour trouver le geojson contenant les infos approchees de geolocalisation du cliche
    # echo "APPEL PYTHON : $ROOT_DIR/OutilsLB/Recherche_Geojason_bdd.py"
    # ls -l "$ROOT_DIR/OutilsLB/Recherche_Geojason_bdd.py"
    python3  $ROOT_DIR/OutilsLB/Recherche_Geojason_bdd.py $ROOT_DIR/index_pva_tif.db ${nomcliche}.${extension} ${nomcliche}.geojson ;
    
    ogr2ogr -t_srs EPSG:2154 ${nomcliche}.L93.geojson ${nomcliche}.geojson ;
    python3 $ROOT_DIR/OutilsLB/GeoJson2ExportCoordTerrain.py ${nomcliche}.L93.geojson ${nomcliche}.L93.coordL93.txt ;
    python3 $ROOT_DIR/OutilsLB/ExportCoordIm_multi.py ${nomcliche}.${extension} ${nomcliche}.coordim ;
    for j in 0 1 2 3 ; do
	# echo ${j} ;
	python3 $ROOT_DIR/OutilsLB/CalculTransfo.py ${nomcliche}.L93.coordL93.txt ${nomcliche}.coordim_rot${j} ${nomcliche}.tfw_rot${j} ;
    done ;
done 
