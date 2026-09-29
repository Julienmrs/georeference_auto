start=$(date +%s)
ROOT_DIR="$( cd "$(dirname $0)" && pwd )"

# Le chantier a traiter est passe en argument
chantier="$1"
if [ -z "${chantier}" ]; then
    echo "Usage : $0 <nom_du_chantier>"
    exit 1
fi
 
exes="$ROOT_DIR/OutilsLB"
cd "$ROOT_DIR/Echantillon_jp2_mars2025/${chantier}" || exit 1
 
# Garde-fou si le script est lance seul : la BDOrtho doit exister et etre lisible
if [ ! -s BDOrtho.tif ] || ! gdalinfo BDOrtho.tif > /dev/null 2>&1; then
    echo "BDOrtho.tif absente ou invalide pour ${chantier}, arret."
    exit 1
fi
 
#adresse_outils_superglue="$ROOT_DIR/essai_20232024/"
adresse_outils_superglue="$ROOT_DIR/OutilsLB/SuperGlue/"
adresseMNT="$ROOT_DIR/OutilsLB/MNT.tif"
 
echo ${chantier} >> $ROOT_DIR/LeonBerard3/journal.txt;
echo "NOUVEAU METHODE GDAL PAM AFFONLY" >> $ROOT_DIR/LeonBerard3/journal.txt;
date >> $ROOT_DIR/LeonBerard3/journal.txt
 
#On fait la liste des cliches en presence
echo -n "" > $ROOT_DIR/Echantillon_jp2_mars2025/liste_cliches.txt
for cliche in IGNF*.tif ; do
    # printf '%q\n' $cliche
    echo ${cliche%.*} >> $ROOT_DIR/Echantillon_jp2_mars2025/liste_cliches.txt
done ;

#    cd georefini
    #On utilise le pre-georeferencement
    echo "Pre-georeferencement" >> $ROOT_DIR/LeonBerard3/journal.txt
    for cliche in `cat $ROOT_DIR/Echantillon_jp2_mars2025/liste_cliches.txt` ; do
	# printf '%q\n' ${cliche}.tif
	# printf '%q\n' ${cliche}.tif
	echo
	mv "${cliche}.tif" "${cliche}_ini.tif"
    	echo ${cliche} >> $ROOT_DIR/LeonBerard3/journal.txt
    	date >> $ROOT_DIR/LeonBerard3/journal.txt
		gdal_translate ${cliche}_ini.tif ${cliche}.tif
		echo -n "" > monbash
		for irot in 0 1 2 3 ; do
			echo "rot${irot}"
			#python3 $ROOT_DIR/OutilsLB/Creer_PAM_from_im_terr.py ${cliche}.coordim_rot${irot} ${cliche}.L93.coordL93.txt ${cliche}.tif.aux.xml
			#gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 ${cliche}.tif ${cliche}.rot${irot}.vrt
			#echo "gdal_translate -r average -tr 10% 10% ${cliche}.rot${irot}.vrt ${cliche}.rot${irot}.tif" >> monbash
			echo "$ROOT_DIR/OutilsLB/LB.LINUX WarpAffinite  --tfw ${cliche}.tfw_rot${irot} --image ${cliche}.tif  --image_sortie ${cliche}.warp10m.rot${irot}.tif --pas_sortie 10 " >> monbash
			#$ROOT_DIR/OutilsLB/LB.LINUX WarpAffinite  --tfw ${cliche}.tfw --image ${cliche}.tif  --image_sortie ${cliche}.warp10m.tif --pas_sortie 10 
			#$ROOT_DIR/OutilsLB/LB.LINUX WarpAffinite  --tfw ${cliche}.tfw --image ${cliche}.tif  --image_sortie ${cliche}.warp.tif  
		done
		$ROOT_DIR/scripts-fromts/code-hiatus/Bash2Make.LINUX monbash monmake
		make -f monmake -j 4
		rm monbash monmake
    done
    mkdir travail_ssech10
    cd travail_ssech10
    echo "Travail" >> "$ROOT_DIR/LeonBerard3/journal.txt"
for cliche in `cat $ROOT_DIR/Echantillon_jp2_mars2025/liste_cliches.txt` ; do
    	echo ${cliche} >> $ROOT_DIR/LeonBerard3/journal.txt
    	date >> $ROOT_DIR/LeonBerard3/journal.txt
	#listgeo -tfw ${cliche}.tif
	cp ../${cliche}.warp10m.rot0.tif ${cliche}.tif
	cp ../${cliche}.warp10m.rot0.tfw ${cliche}.tfw
	#gdalbuildvrt BDOrtho.vrt ../Correspondances_ortho_actuelles/*.jp2
	gdalbuildvrt BDOrtho.vrt ../BDOrtho.tif 
	gdaltindex ${cliche}.shp ${cliche}.tif
	gdalwarp -overwrite -cutline ${cliche}.shp -r average -crop_to_cutline -tr 10 10 -overwrite BDOrtho.vrt ${cliche}.BDOrtho.tif
	listgeo -tfw ${cliche}.BDOrtho.tif
	echo "Choix rotation" >> $ROOT_DIR/LeonBerard3/journal.txt
	for irot in 0 1 2 3 ; do
	    cp ../${cliche}.warp10m.rot${irot}.tif ${cliche}.tif
	    cp ../${cliche}.warp10m.rot${irot}.tfw ${cliche}.tfw
	    #Methode HIATUS
	    $ROOT_DIR/scripts-fromts/code-hiatus/MethodeAubry.LINUX  ${cliche}.BDOrtho.tif ${cliche}.BDOrtho.kaub --maxlocaux --SigmaInv $ROOT_DIR/scripts-fromts/code-hiatus/SigmaInvAubry.tif --Mu $ROOT_DIR/scripts-fromts/code-hiatus/MuAubry.tif > /dev/null
	    $ROOT_DIR/scripts-fromts/code-hiatus/MethodeAubryAppariement.LINUX Points:Image ${cliche}.BDOrtho.kaub ${cliche}.tif ${cliche}.BDOrtho.-.${cliche}.resultpi  --SigmaInv $ROOT_DIR/scripts-fromts/code-hiatus/SigmaInvAubry.tif --Mu $ROOT_DIR/scripts-fromts/code-hiatus/MuAubry.tif --agarder 0.5 > /dev/null
	    $ROOT_DIR/scripts-fromts/code-hiatus/RANSAC ${cliche}.BDOrtho.-.${cliche}.resultpi ${cliche}.BDOrtho.-.${cliche}.resultpif_rot${irot} > /dev/null

	    #Methode SuperGlue 
	    python3 $ROOT_DIR/OutilsLB/SuperGlue/MetaSuperGlueTer.py ${cliche}.BDOrtho.tif ${cliche}.tif ${cliche}.BDOrtho.-.${cliche}.resultspg
	    $ROOT_DIR/scripts-fromts/code-hiatus/RANSAC ${cliche}.BDOrtho.-.${cliche}.resultspg ${cliche}.BDOrtho.-.${cliche}.resultspgf_rot${irot} > /dev/null

	done

	python3 $ROOT_DIR/OutilsLB/ChoixMeilleurApp.py ${cliche}.BDOrtho.-.${cliche}.resultpif_rot0  ${cliche}.BDOrtho.-.${cliche}.resultpif_rot1 ${cliche}.BDOrtho.-.${cliche}.resultpif_rot2 ${cliche}.BDOrtho.-.${cliche}.resultpif_rot3 > ${cliche}.BDOrtho.-.${cliche}.best
	irotbest=0
	for a in `cat ${cliche}.BDOrtho.-.${cliche}.best` ; do
	    irotbest=${a}
	done
	echo ${irotbest} est la meilleure rotation pour ${cliche} >> $ROOT_DIR/LeonBerard3/journal.txt
	echo ${irotbest} > ${cliche}.rotbest.txt
	cp ${cliche}.BDOrtho.-.${cliche}.resultspgf_rot${irotbest} ${cliche}.BDOrtho.-.${cliche}.resultspgf
	cp ${cliche}.BDOrtho.-.${cliche}.resultpif_rot${irotbest} ${cliche}.BDOrtho.-.${cliche}.resultpif
	cp ../${cliche}.warp10m.rot${irotbest}.tif ${cliche}.tif
	cp ../${cliche}.warp10m.rot${irotbest}.tfw ${cliche}.tfw
	cp ../${cliche}.tfw_rot${irotbest} ../${cliche}.tfw
	cp ../${cliche}.warp10m.rot${irotbest}.tif ../${cliche}.warp10m.tif
	cp ../${cliche}.warp10m.rot${irotbest}.tfw ../${cliche}.warp10m.tfw
	python3 $ROOT_DIR/OutilsLB/Creer_PAM_from_im_terr.py ../${cliche}.coordim_rot${irotbest} ../${cliche}.L93.coordL93.txt ../${cliche}.tif.aux.xml
	#rm ../${cliche}.warp10m.rot*
	
	#Methode HIATUS
	echo "Methode kaub" >> $ROOT_DIR/LeonBerard3/journal.txt
	$ROOT_DIR/OutilsLB/LB.LINUX CalculTransfo2D:Affinite ${cliche}.BDOrtho.-.${cliche}.resultpif ${cliche}.aff.modelekaub.txt > /dev/null
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo ../${cliche}.tfw ${cliche}.tfw ${cliche}.aff.modelekaub.txt ${cliche}.BDOrtho.tfw  ${cliche}.modelefinal.affkaub.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHomographie --tfw ${cliche}.modelefinal.affkaub.txt --image ../${cliche}.tif --image_sortie ${cliche}.affkaub.tif --modele_inverse
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo:tfw ../${cliche}.tfw ${cliche}.tfw ${cliche}.aff.modelekaub.txt ${cliche}.BDOrtho.tfw  ${cliche}.modelefinal.affkaub.tfw 
	python3 $ROOT_DIR/OutilsLB/Creer_PAM_from_im_tfw.py ../${cliche}.coordim_rot0 ${cliche}.modelefinal.affkaub.tfw ${cliche}.modelefinal.affkaub.tif.aux.xml ; #ln -s ../${cliche}.tif ${cliche}.modelefinal.affkaub.tif ; gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 ${cliche}.modelefinal.affkaub.tif ${cliche}.modelefinal.affkaub.tif.vrt ; gdal_translate -co COMPRESS=DEFLATE ${cliche}.modelefinal.affkaub.tif.vrt ${cliche}.modelefinal.affkaub.tif ; rm 
	
	#Methode SuperGlue (pour le moment a la main)
	echo "Methode spg" >> $ROOT_DIR/LeonBerard3/journal.txt
	#$ROOT_DIR/estimHomog.LINUX ${cliche}.BDOrtho.-.${cliche}.resultspgf > /dev/null ; mv modele.txt ${cliche}.hom.modelespg.txt
	$ROOT_DIR/OutilsLB/LB.LINUX CalculTransfo2D:Affinite ${cliche}.BDOrtho.-.${cliche}.resultspgf ${cliche}.aff.modelespg.txt > /dev/null
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo ../${cliche}.tfw ${cliche}.tfw ${cliche}.aff.modelespg.txt ${cliche}.BDOrtho.tfw  ${cliche}.modelefinal.affspg.txt	
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHomographie --tfw ${cliche}.modelefinal.affspg.txt --image ../${cliche}.tif --image_sortie ${cliche}.affspg.tif --modele_inverse
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo:tfw ../${cliche}.tfw ${cliche}.tfw ${cliche}.aff.modelespg.txt ${cliche}.BDOrtho.tfw  ${cliche}.modelefinal.affspg.tfw
	python3 $ROOT_DIR/OutilsLB/Creer_PAM_from_im_tfw.py ../${cliche}.coordim_rot0 ${cliche}.modelefinal.affspg.tfw ${cliche}.modelefinal.affspg.tif.aux.xml ; #ln -s ../${cliche}.tif ${cliche}.modelefinal.affspg.tif ; gdalwarp -overwrite -r bilinear -t_srs EPSG:2154 -order 1 ${cliche}.modelefinal.affspg.tif ${cliche}.modelefinal.affspg.tif.vrt ; gdal_translate -co COMPRESS=DEFLATE ${cliche}.modelefinal.affspg.tif.vrt ${cliche}.modelefinal.affspg.tif ; rm 


	#Pour export points
	$ROOT_DIR/OutilsLB/LB.LINUX ScindeResult ${cliche}.BDOrtho.-.${cliche}.resultpif ${cliche}.BDOrtho.ptskaub ${cliche}.ptskaub
	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueAffinitePts --tfw ${cliche}.BDOrtho.tfw --pts_entree ${cliche}.BDOrtho.ptskaub --pts_sortie ${cliche}.BDOrtho.ptskaub
	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueAffinitePts --tfw ${cliche}.tfw --pts_entree ${cliche}.ptskaub --pts_sortie ${cliche}.ptstmp
	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueAffinitePts --tfw ../${cliche}.tfw --pts_entree ${cliche}.ptstmp --pts_sortie ${cliche}.ptstmp --modele_inverse

	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueHomographiePts --tfw ${cliche}.modelefinal.affkaub.txt --pts_entree ${cliche}.ptstmp --pts_sortie ${cliche}.ptsreproj.aff.modelekaub --modele_inverse
	$ROOT_DIR/OutilsLB/LB.LINUX Txt2GeoJson ${cliche}.ptsreproj.aff.modelekaub ${cliche}.ptsreproj.aff.modelekaub.geojson
	
	$ROOT_DIR/OutilsLB/LB.LINUX Txt2GeoJson ${cliche}.BDOrtho.ptskaub ${cliche}.BDOrtho.ptskaub.geojson

	#Pour export points
	$ROOT_DIR/OutilsLB/LB.LINUX ScindeResult ${cliche}.BDOrtho.-.${cliche}.resultspgf ${cliche}.BDOrtho.ptsspg ${cliche}.ptsspg
	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueAffinitePts --tfw ${cliche}.BDOrtho.tfw --pts_entree ${cliche}.BDOrtho.ptsspg --pts_sortie ${cliche}.BDOrtho.ptsspg
	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueAffinitePts --tfw ${cliche}.tfw --pts_entree ${cliche}.ptsspg --pts_sortie ${cliche}.ptstmp
	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueAffinitePts --tfw ../${cliche}.tfw --pts_entree ${cliche}.ptstmp --pts_sortie ${cliche}.ptstmp --modele_inverse

	$ROOT_DIR/OutilsLB/LB.LINUX AppliqueHomographiePts --tfw ${cliche}.modelefinal.affspg.txt --pts_entree ${cliche}.ptstmp --pts_sortie ${cliche}.ptsreproj.aff.modelespg --modele_inverse
	$ROOT_DIR/OutilsLB/LB.LINUX Txt2GeoJson ${cliche}.ptsreproj.aff.modelespg ${cliche}.ptsreproj.aff.modelespg.geojson	

	$ROOT_DIR/OutilsLB/LB.LINUX Txt2GeoJson ${cliche}.BDOrtho.ptsspg ${cliche}.BDOrtho.ptsspg.geojson

	

done


end=$(date +%s)
echo "Temps écoulé : $((end - start)) s"