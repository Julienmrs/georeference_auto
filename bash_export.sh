timestart=$SECONDS
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $ROOT_DIR/Echantillon_jp2_mars2025

mkdir final
for chantier in `cat liste_chantiers.txt`; do
    echo ${chantier}
    mkdir final/${chantier}
    for cliche in `cat ${chantier}/liste_cliches.txt`; do
	echo ${cliche}
	cp ${chantier}/travail_ssech10/${cliche}.modelefinal.affkaub.tif.aux.xml final/${chantier}/${cliche}.tif.aux.xml
	cp ${chantier}/${cliche}.tif final/${chantier}/${cliche}.tif
	gdaladdo -r average -ro final/${chantier}/${cliche}.tif 8 16
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 final/${chantier}/${cliche}.tif final/${chantier}/${cliche}.vrt 
	# etape bis
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 final/${chantier}/${cliche}.tif final/${chantier}/${cliche}_georef.tif 
	gdaladdo -r average -ro final/${chantier}/${cliche}_georef.tif 8 16
    done
done
	
mkdir final_spg
for chantier in `cat liste_chantiers.txt`; do
    echo ${chantier}
    mkdir final_spg/${chantier}
    for cliche in `cat ${chantier}/liste_cliches.txt`; do
	echo ${cliche}
	cp ${chantier}/travail_ssech10/${cliche}.modelefinal.affspg.tif.aux.xml final_spg/${chantier}/${cliche}.tif.aux.xml
#	ln -s final/${chantier}/${cliche}.tif final_spg/${chantier}/${cliche}.tif
	cp final/${chantier}/${cliche}.tif final_spg/${chantier}/${cliche}.tif
	gdaladdo -r average -ro final_spg/${chantier}/${cliche}.tif 8 16
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 final_spg/${chantier}/${cliche}.tif final_spg/${chantier}/${cliche}.vrt 
	# etape bis
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 final_spg/${chantier}/${cliche}.tif final_spg/${chantier}/${cliche}_georef.tif 
	gdaladdo -r average -ro final_spg/${chantier}/${cliche}_georef.tif 8 16
    done
done

mkdir initial
for chantier in `cat liste_chantiers.txt`; do
    echo ${chantier}
    mkdir initial/${chantier}
    for cliche in `cat ${chantier}/liste_cliches.txt`; do
	echo ${cliche}
	cp ${chantier}/${cliche}.tif.aux.xml initial/${chantier}/${cliche}.tif.aux.xml
	cp final/${chantier}/${cliche}.tif initial/${chantier}/${cliche}.tif
	gdaladdo -r average -ro initial/${chantier}/${cliche}.tif 8 16
	#ln -s final/${chantier}/${cliche}.tif initial/${chantier}/${cliche}.tif
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 initial/${chantier}/${cliche}.tif initial/${chantier}/${cliche}.vrt 
	# etape bis		
	gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 initial/${chantier}/${cliche}.tif initial/${chantier}/${cliche}_georef.tif 
	gdaladdo -r average -ro initial/${chantier}/${cliche}_georef.tif 8 16
	
    done
done
echo  "Temps total : $(( SECONDS - timestart )) secondes"
echo "$(( SECONDS - timestart ))" >> $ROOT_DIR/temps.txt