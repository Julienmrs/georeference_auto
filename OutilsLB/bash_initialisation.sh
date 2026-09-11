#On attend ici la liste des chemins vers les differents fichiers jp2 
conda deactivate
conde deactivate
for cliches in `cat liste_cliches.txt`; 
    do nomcliche=${cliche%.*} ;
        echo ${nomcliche} ; 
        python Recherche_Geojason_bdd.py $ROOT_DIR/photos-aeriennes-ign-master/data/pva ${nomcliche}.jp2 ;
        ogr2ogr -t_srs EPSG:2154 ${nomcliche}.L93.geojson ${nomcliche}.geojson ;
        python ../GeoJson2ExportCoordTerrain.py ${nomcliche}.L93.geojson ${nomcliche}.L93.coordL93.txt ; 
        python3 $ROOT_DIR/ExportCoordIm_multi.py ${nomcliche}.jp2 ${nomcliche}.coordim ; for j in 0 1 2 3 ; do echo ${j} ;  
        python3 $ROOT_DIR/CalculTransfo.py ${nomcliche}.L93.coordL93.txt ${nomcliche}.coordim_rot${j} ${nomcliche}.tfw_rot${j} ; 
    done ; 
done 
