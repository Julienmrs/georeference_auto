timestart=$SECONDS
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $ROOT_DIR/Echantillon_jp2_mars2025
mkdir final_5m
for chantier in `cat liste_chantiers.txt`; do
    echo ${chantier}
    mkdir final_5m/${chantier}
    for cliche in `cat ${chantier}/liste_cliches.txt`; do
	echo ${cliche}
	cp ${chantier}/travail_ssech5/${cliche}.modelefinal.affkaub.tif.aux.xml final_5m/${chantier}/${cliche}.tif.aux.xml
	cp ${chantier}/${cliche}.tif final_5m/${chantier}/${cliche}.tif
	gdaladdo -r average -ro final_5m/${chantier}/${cliche}.tif 8 16
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 final_5m/${chantier}/${cliche}.tif final_5m/${chantier}/${cliche}.vrt 
    done
done
	
mkdir final_spg_5m
for chantier in `cat liste_chantiers.txt`; do
    echo ${chantier}
    mkdir final_spg_5m/${chantier}
    for cliche in `cat ${chantier}/liste_cliches.txt`; do
	echo ${cliche}
	cp ${chantier}/travail_ssech5/${cliche}.modelefinal.affspg.tif.aux.xml final_spg_5m/${chantier}/${cliche}.tif.aux.xml
#	ln -s final/${chantier}/${cliche}.tif final_spg_5m/${chantier}/${cliche}.tif
	cp final/${chantier}/${cliche}.tif final_spg_5m/${chantier}/${cliche}.tif
	gdaladdo -r average -ro final_spg_5m/${chantier}/${cliche}.tif 8 16
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 final_spg_5m/${chantier}/${cliche}.tif final_spg_5m/${chantier}/${cliche}.vrt 
    done
done
echo  "Temps total : $(( SECONDS - timestart )) secondes"
echo "$(( SECONDS - timestart ))" >> $ROOT_DIR/temps.txt
