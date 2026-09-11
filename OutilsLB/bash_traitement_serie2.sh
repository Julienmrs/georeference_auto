exes="$ROOT_DIR/OutilsLB"
conda activate SuperGlue
#adresse_outils_superglue="$ROOT_DIR/essai_20232024/"
adresse_outils_superglue="$ROOT_DIR/OutilsLB/SuperGlue/"
adresseMNT="$ROOT_DIR/OutilsLB/MNT.tif"

for chantier in `cat liste_chantiers.txt` ; do
    echo ${chantier};
    cd ${chantier}
    #On fait la liste des cliches en presence
    echo -n "" > liste_cliches.txt
    for cliche in *.jp2 ; do 
	echo ${cliche%.*} >> liste_cliches.txt
    done ;
#    cd georefini
    #On utilise le pre-georeferencement
    for cliche in `cat liste_cliches.txt` ; do
	gdal_translate ${cliche}.jp2 ${cliche}.tif
	echo -n "" > monbash
	for irot in 0 1 2 3 ; do  
	    echo "$ROOT_DIR/OutilsLB/LB.LINUX WarpAffinite  --tfw ${cliche}.tfw_rot${irot} --image ${cliche}.tif  --image_sortie ${cliche}.warp10m.rot${irot}.tif --pas_sortie 10 " >> monbash
#	$ROOT_DIR/OutilsLB/LB.LINUX WarpAffinite  --tfw ${cliche}.tfw --image ${cliche}.tif  --image_sortie ${cliche}.warp10m.tif --pas_sortie 10 
#	$ROOT_DIR/OutilsLB/LB.LINUX WarpAffinite  --tfw ${cliche}.tfw --image ${cliche}.tif  --image_sortie ${cliche}.warp.tif  
	done
	$ROOT_DIR/scripts-fromts/code-hiatus/Bash2Make.LINUX monbash monmake
	make -f monmake -j 4
	rm monbash monmake
    done
    mkdir travail_ssech10
    cd travail_ssech10
    for cliche in `cat ../liste_cliches.txt` ; do
	#gdal_translate -tr 10 10 -r average  ../georefini/${cliche}.warp.tif ${cliche}.tif
	#listgeo -tfw ${cliche}.tif
	cp ../${cliche}.warp10m.rot0.tif ${cliche}.tif
	cp ../${cliche}.warp10m.rot0.tfw ${cliche}.tfw
	gdalbuildvrt BDOrtho.vrt ../Correspondances_ortho_actuelles/*.jp2
	gdaltindex ${cliche}.shp ${cliche}.tif
	gdalwarp -cutline ${cliche}.shp -r average -crop_to_cutline -tr 10 10 -overwrite BDOrtho.vrt ${cliche}.BDOrtho.tif
	listgeo -tfw ${cliche}.BDOrtho.tif

	for irot in 0 1 2 3 ; do
	    cp ../${cliche}.warp10m.rot${irot}.tif ${cliche}.tif
	    cp ../${cliche}.warp10m.rot${irot}.tfw ${cliche}.tfw
	    #Methode HIATUS
	    $ROOT_DIR/scripts-fromts/code-hiatus/MethodeAubry.LINUX  ${cliche}.BDOrtho.tif ${cliche}.BDOrtho.kaub --maxlocaux --SigmaInv $ROOT_DIR/scripts-fromts/code-hiatus/SigmaInvAubry.tif --Mu $ROOT_DIR/scripts-fromts/code-hiatus/MuAubry.tif > /dev/null
	    $ROOT_DIR/scripts-fromts/code-hiatus/MethodeAubryAppariement.LINUX Points:Image ${cliche}.BDOrtho.kaub ${cliche}.tif ${cliche}.BDOrtho.-.${cliche}.resultpi  --SigmaInv $ROOT_DIR/scripts-fromts/code-hiatus/SigmaInvAubry.tif --Mu $ROOT_DIR/scripts-fromts/code-hiatus/MuAubry.tif --agarder 0.5 > /dev/null
	    $ROOT_DIR/scripts-fromts/code-hiatus/RANSAC ${cliche}.BDOrtho.-.${cliche}.resultpi ${cliche}.BDOrtho.-.${cliche}.resultpif_rot${irot} > /dev/null

	    #Methode SuperGlue (pour le moment a la main)
	    #pwd > monadresse.txt
	    #adressecourante=`cat monadresse.txt`
	    #rm monadresse.txt
	    #mkdir im2match
	    #cd ${adresse_outils_superglue} 
	    #echo ${adressecourante}
	    #cp ${adressecourante}/${cliche}.BDOrtho.tif im2match/new.tif 
	    #cp ${adressecourante}/${cliche}.tif im2match/old.tif
	    #python MetaSuperGlue.py
	    ##/host/test_viewer/ViewerPointsInteretEtDependances/ViewerPointsInteret/build/TEST_SIFT2 new.-.old.result im2match/new.tif im2match/old.tif
	    #mv new.-.old.result ${adressecourante}/${cliche}.BDOrtho.-.${cliche}.resultspg
	    #cd ${adressecourante}
	    python $ROOT_DIR/OutilsLB/SuperGlue/MetaSuperGlueTer.py ${cliche}.BDOrtho.tif ${cliche}.tif ${cliche}.BDOrtho.-.${cliche}.resultspg
	    $ROOT_DIR/scripts-fromts/code-hiatus/RANSAC ${cliche}.BDOrtho.-.${cliche}.resultspg ${cliche}.BDOrtho.-.${cliche}.resultspgf_rot${irot} > /dev/null

	done

	#Il manque un module pour identifier celui qui a eu le meilleur score !
	python $ROOT_DIR/OutilsLB/ChoixMeilleurApp.py ${cliche}.BDOrtho.-.${cliche}.resultpif_rot0  ${cliche}.BDOrtho.-.${cliche}.resultpif_rot1 ${cliche}.BDOrtho.-.${cliche}.resultpif_rot2 ${cliche}.BDOrtho.-.${cliche}.resultpif_rot3 > ${cliche}.BDOrtho.-.${cliche}.best
	irotbest=0
	for a in `cat ${cliche}.BDOrtho.-.${cliche}.best` ; do
	    irotbest=${a}
	done
	echo ${irotbest}
	cp ${cliche}.BDOrtho.-.${cliche}.resultspgf_rot${irotbest} ${cliche}.BDOrtho.-.${cliche}.resultspgf
	cp ${cliche}.BDOrtho.-.${cliche}.resultpif_rot${irotbest} ${cliche}.BDOrtho.-.${cliche}.resultpif
	cp ../${cliche}.warp10m.rot${irotbest}.tif ${cliche}.tif
	cp ../${cliche}.warp10m.rot${irotbest}.tfw ${cliche}.tfw
	cp ../${cliche}.tfw_rot${irotbest} ../${cliche}.tfw
	cp ../${cliche}.warp10m.rot${irotbest}.tif ../${cliche}.warp10m.tif
	cp ../${cliche}.warp10m.rot${irotbest}.tfw ../${cliche}.warp10m.tfw
	#rm ../${cliche}.warp10m.rot*
	
	#Methode HIATUS
	#$ROOT_DIR/estimHomog.LINUX ${cliche}.BDOrtho.-.${cliche}.resultpif > /dev/null ; mv modele.txt ${cliche}.hom.modelekaub.txt
	$ROOT_DIR/OutilsLB/LB.LINUX CalculTransfo2D:Homographie ${cliche}.BDOrtho.-.${cliche}.resultpif ${cliche}.hom.modelekaub.txt > /dev/null
	$ROOT_DIR/OutilsLB/LB.LINUX CalculTransfo2D:Affinite ${cliche}.BDOrtho.-.${cliche}.resultpif ${cliche}.aff.modelekaub.txt > /dev/null

	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo ../${cliche}.tfw ${cliche}.tfw ${cliche}.hom.modelekaub.txt ${cliche}.BDOrtho.tfw  modele.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHomographie --tfw modele.txt --image ../${cliche}.tif --image_sortie ${cliche}.homkaub.tif --modele_inverse
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo ../${cliche}.tfw ${cliche}.tfw ${cliche}.aff.modelekaub.txt ${cliche}.BDOrtho.tfw  modele.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHomographie --tfw modele.txt --image ../${cliche}.tif --image_sortie ${cliche}.affkaub.tif --modele_inverse

	#Pour faire une "vraie" ortho
	$ROOT_DIR/OutilsLB/LB.LINUX ScindeResult ${cliche}.BDOrtho.-.${cliche}.resultpif ${cliche}.ptsref.txt ${cliche}.ptsarec.txt
	$ROOT_DIR/OutilsLB/LB.LINUX ImageToTerrain ${cliche}.ptsref.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsrefEN.txt
	$ROOT_DIR/OutilsLB/LB.LINUX ImageToTerrain ${cliche}.ptsarec.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsarecEN.txt
	$ROOT_DIR/OutilsLB/LB.LINUX GetZ ${cliche}.ptsrefEN.txt ${adresseMNT} ${cliche}.ptsrefENh.txt
	$ROOT_DIR/OutilsLB/LB.LINUX TerrainToImage ${cliche}.ptsarecEN.txt ../${cliche}.tfw ${cliche}.ptsarecimini.txt
	$ROOT_DIR/OutilsLB/LB.LINUX CalculHom11p ${cliche}.ptsarecimini.txt ${cliche}.ptsrefENh.txt  
	mv modele_h11.txt ${cliche}.modele_h11.kaub.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHom11p ${cliche}.modele_h11.kaub.txt ${adresseMNT} ../${cliche}.tif ${cliche}.h11kaub.tif 

	
	#Methode SuperGlue (pour le moment a la main)
	#$ROOT_DIR/estimHomog.LINUX ${cliche}.BDOrtho.-.${cliche}.resultspgf > /dev/null ; mv modele.txt ${cliche}.hom.modelespg.txt
	$ROOT_DIR/OutilsLB/LB.LINUX CalculTransfo2D:Homographie ${cliche}.BDOrtho.-.${cliche}.resultspgf ${cliche}.hom.modelespg.txt > /dev/null
	$ROOT_DIR/OutilsLB/LB.LINUX CalculTransfo2D:Affinite ${cliche}.BDOrtho.-.${cliche}.resultspgf ${cliche}.aff.modelespg.txt > /dev/null
	
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo ../${cliche}.tfw ${cliche}.tfw ${cliche}.hom.modelespg.txt ${cliche}.BDOrtho.tfw  modele.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHomographie --tfw modele.txt --image ../${cliche}.tif --image_sortie ${cliche}.homspg.tif --modele_inverse
	$ROOT_DIR/OutilsLB/LB.LINUX EnchainementTransfo ../${cliche}.tfw ${cliche}.tfw ${cliche}.aff.modelespg.txt ${cliche}.BDOrtho.tfw  modele.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHomographie --tfw modele.txt --image ../${cliche}.tif --image_sortie ${cliche}.affspg.tif --modele_inverse
	
	#Pour faire une "vraie" ortho
	$ROOT_DIR/OutilsLB/LB.LINUX ScindeResult ${cliche}.BDOrtho.-.${cliche}.resultspgf ${cliche}.ptsref.txt ${cliche}.ptsarec.txt
	$ROOT_DIR/OutilsLB/LB.LINUX ImageToTerrain ${cliche}.ptsref.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsrefEN.txt
	$ROOT_DIR/OutilsLB/LB.LINUX ImageToTerrain ${cliche}.ptsarec.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsarecEN.txt
	$ROOT_DIR/OutilsLB/LB.LINUX GetZ ${cliche}.ptsrefEN.txt ${adresseMNT} ${cliche}.ptsrefENh.txt
	$ROOT_DIR/OutilsLB/LB.LINUX TerrainToImage ${cliche}.ptsarecEN.txt ../${cliche}.tfw ${cliche}.ptsarecimini.txt
	$ROOT_DIR/OutilsLB/LB.LINUX CalculHom11p ${cliche}.ptsarecimini.txt ${cliche}.ptsrefENh.txt  
	mv modele_h11.txt ${cliche}.modele_h11.txt
	$ROOT_DIR/OutilsLB/LB.LINUX WarpHom11p ${cliche}.modele_h11.txt ${adresseMNT} ../${cliche}.tif ${cliche}.h11spg.tif 

    done
    cd ../
    cd ../
    cd ../
done
