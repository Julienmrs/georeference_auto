cd /mnt/data/HIATUS/sites/strasbourg/data/$1
repertoire_scripts="/mnt/data/HIATUS/code-hiatus"
nbcpus="64"
pasdallage="1000"
rm -r TraitementAPP
mkdir TraitementAPP
cd TraitementAPP
ls ../Ortho-MEC-Malt-Abs/Orthophotomosaic_Tile_*.tif > liste_tile.txt
mkdir dallage
#${repertoire_scripts}/convert_ori.LINUX tfw2ori ../Ortho-MEC-Malt-Abs/Orthophotomosaic.tfw Orthophotomosaic.ori
#On commence par daller les differentes orthoimages deja generees
for i in `cat liste_tile.txt` ; do
fichier=$(basename ${i})
nomdalle=${fichier%.*}
ln -s ../Ortho-MEC-Malt-Abs/${nomdalle}.tif .
${repertoire_scripts}/convert_ori.LINUX tfw2ori ../Ortho-MEC-Malt-Abs/${nomdalle}.tfw ${nomdalle}.ori
${repertoire_scripts}/Split.LINUX ${nomdalle}.tif ${pasdallage} ${pasdallage} dallage/${nomdalle}
done
#On fait la liste des dalles creees
ls dallage/*.tif > liste_dalles.txt
for i in `cat liste_dalles.txt` ; do
fichier=$(basename ${i})
fichiersansext=`echo ${fichier}|cut -d"." -f1`
echo $fichiersansext >> liste_dalles_tmp
done
mv liste_dalles_tmp liste_dalles.txt
#Lister la BDOrtho
ls ../../../metadata/ortho/*.TFW ../../../metadata/ortho/*.tfw > liste_bdortho.txt
for i in `cat liste_bdortho.txt` ; do 
${repertoire_scripts}/convert_ori.LINUX tfw2ori ${i} 
done
ls ../../../metadata/ortho/*.TIF ../../../metadata/ortho/*.tif > liste_bdortho.txt
echo -n "" > bashtmp
for i in `cat liste_dalles.txt` ; do 
#On cree une dalle d ortho superposable (a terme rajouter des marges ?)
echo -n "${repertoire_scripts}/HIATUS DecalageDalle:CropResult dallage/${i}.ori ../TraitementAPPssech10/resultpi dallage/${i}.pregeoref 5000 ; " >> bashtmp ;
echo -n "${repertoire_scripts}/RANSAC dallage/${i}.pregeoref dallage/${i}.pregeoreff --adresse_export_best_modele dallage/${i}.pregeoref_modsim > /dev/null ; " >> bashtmp ;
echo -n "${repertoire_scripts}/HIATUS DecalageDalle:FromSim dallage/${i}.ori dallage/${i}.pregeoref_modsim > dallage/${i}.T.txt ; " >> bashtmp ;
#echo -n "${repertoire_scripts}/HIATUS DecalageDalle dallage/${i}.ori ../TraitementAPPssech10/resultpi 5000 200 > dallage/${i}.T.txt ; " >> bashtmp ;
echo -n "${repertoire_scripts}/HIATUS TranslatOri:m dallage/${i}.ori dallage/${i}.T.txt dallage/${i}.decal.ori ; " >> bashtmp ;
echo -n "${repertoire_scripts}/Decoupage.LINUX dallage/${i}.decal.ori liste_bdortho.txt dallage/bdortho_${i}.tif > /dev/null ; " >> bashtmp ;
echo "${repertoire_scripts}/Ech_noif.LINUX Format dallage/bdortho_${i}.tif dallage/bdortho_${i}.tif ; " >> bashtmp ;
done
${repertoire_scripts}/Bash2Make.LINUX bashtmp monmaketmp
make -k -f monmaketmp -j 1;

echo -n "" > bashtmp
for i in `cat liste_dalles.txt` ; do 
#Detection des points d interet
echo "${repertoire_scripts}/MethodeAubry.LINUX dallage/bdortho_${i}.tif dallage/bdortho_${i}.kaub --maxlocaux --Mu ${repertoire_scripts}/MuAubry.tif --SigmaInv ${repertoire_scripts}/SigmaInvAubry.tif > /dev/null ; " >> bashtmp ;
done
${repertoire_scripts}/Bash2Make.LINUX bashtmp monmaketmp
make -k -f monmaketmp -j ${nbcpus};

echo -n "" > bashtmp
for i in `cat liste_dalles.txt` ; do 
echo "${repertoire_scripts}/FiltrageMasqueDilat.LINUX --image dallage/bdortho_${i}.tif --rayon 10 --kp:bin dallage/bdortho_${i}.kaub --out dallage/bdortho_${i}.kaub > /dev/null ; " >> bashtmp ;
done
${repertoire_scripts}/Bash2Make.LINUX bashtmp monmaketmp
make -k -f monmaketmp -j 10;

#Mise en correspondance 
echo -n "" > bashtmp
for i in `cat liste_dalles.txt` ; do 
echo "${repertoire_scripts}/MethodeAubryAppariement.LINUX Points:Image dallage/bdortho_${i}.kaub dallage/${i}.tif dallage/${i}.resultpi --Mu ${repertoire_scripts}/MuAubry.tif --SigmaInv ${repertoire_scripts}/SigmaInvAubry.tif > /dev/null ; " >> bashtmp 
#On supprime les points situes dans les zones "noires"
${repertoire_scripts}/Bash2Make.LINUX bashtmp monmaketmp
make -k -f monmaketmp -j ${nbcpus};

echo -n "" > bashtmp
for i in `cat liste_dalles.txt` ; do 
echo -n "${repertoire_scripts}/HIATUS NettoyageResultZoneNoire  dallage/${i}.resultpi dallage/${i}.tif dallage/${i}.resultpi > /dev/null ; " >> bashtmp 
#On reprojette les coordonnees dans un referentiel commun (coordonnees images dans l ori de Orthophotomosaic) --> A faire en mieux
echo "${repertoire_scripts}/HIATUS Reproj dallage/${i}.resultpi dallage/bdortho_${i}.ori dallage/${i}.ori Orthophotomosaic.ori Orthophotomosaic.ori dallage/${i}.resultpireproj " >> bashtmp
#echo "rm dallage/${i}.tif dallage/bdortho_${i}.tif " >> bashtmp
done
${repertoire_scripts}/Bash2Make.LINUX bashtmp monmaketmp
make -k -f monmaketmp -j 10;


#On rassemble tous les appariements dans un meme fichier
echo -n "" > resultpi
for i in `cat liste_dalles.txt` ; do 
cat dallage/${i}.resultpireproj >> resultpi ;
done
###################################################################
#On aborde maintenant la partie traitee en local
${repertoire_scripts}/RANSAC resultpi resultpif --taille_case 5000 > /dev/null
#On reprojette en terrain
${repertoire_scripts}/HIATUS ReprojTerrain resultpif Orthophotomosaic.ori Orthophotomosaic.ori resultpifreproj
#On va aller chercher les z associe a ces points
${repertoire_scripts}/HIATUS ExportAsTxt resultpifreproj pts_bdortho.txt pts_orthomicmac_abs.txt
${repertoire_scripts}/HIATUS ExportAsGJson resultpifreproj pts_bdortho.geojson pts_orthomicmac_abs.geojson
###################################################################
#On aborde maintenant la partie avec MNS...
ls ../../../metadata/mns/*.HDR ../../../metadata/mns/*.hdr > liste_mns_bdortho.txt
for i in `cat liste_mns_bdortho.txt` ; do ${repertoire_scripts}/convert_ori.LINUX hdr2ori ${i} ; done
ls ../../../metadata/mns/*.TIF ../../../metadata/mns/*.tif > liste_mns_bdortho.txt
#Creation de la liste des MNS MICMAC a utiliser
ls ../MEC-Malt-Abs/MNS_Final*.tfw > liste_mnsmicmac.txt
for i in `cat liste_mnsmicmac.txt` ; do ${repertoire_scripts}/convert_ori.LINUX tfw2ori ${i} ; done
ls ../MEC-Malt-Abs/MNS_Final*.tif > liste_mnsmicmac.txt
${repertoire_scripts}/HIATUS AssocierZ_fichierpts2D:multiMNS pts_bdortho.txt liste_mns_bdortho.txt pts3D_bdortho.txt ; 
${repertoire_scripts}/HIATUS AssocierZ_fichierpts2D:multiMNS pts_orthomicmac_abs.txt liste_mnsmicmac.txt pts3D_orthomicmac_abs.txt
#On recharge les deux fichiers 3D pour nettoyage des valeurs aberrantes (nodata = 9999) et preparation de letape suivante.
${repertoire_scripts}/HIATUS BilanPts3D pts3D_bdortho.txt pts3D_orthomicmac_abs.txt pts3D_bdortho_net.txt pts3D_orthomicmac_abs_net.txt
#On va mettre en forme pour Apero/micmac
#Faire la liste des cliches
ls ../OIS-*.tif > liste_cliches.txt
echo -n "" > liste_cliches_tmp
for i in `cat liste_cliches.txt` ; do
fichier=$(basename ${i})
fichiersansext=`echo ${fichier}|cut -d"." -f1`
echo $fichiersansext >> liste_cliches_tmp
done
mv liste_cliches_tmp liste_cliches.txt
#Pour chaque cliche, reprojeter les differents points
#Relire sur l ensemble des cliches
cd ..
for i in `cat TraitementAPP/liste_cliches.txt` ; do 
${repertoire_scripts}/mm3d-pour-reproj TestLib PersoALB Ori-Abs/Orientation-${i}.tif.xml TraitementAPP/pts3D_orthomicmac_abs_net.txt TraitementAPP/${i}.tif.pts2d
done
cd TraitementAPP
#Maintenant, on peut relire tous les fichiers et ecrire ce qui est attendu par micmac..
${repertoire_scripts}/HIATUS BilanApp2MICMAC pts3D_bdortho_net.txt liste_cliches.txt ../MesuresAppuis-S2D.xml ../MesuresAppuis-S3D.xml ../appuis.xml ../id_appuis.txt 
cd ..
#Maintenant debute le calcul d aero
#rm -r Tmp-MM-Dir/Ori--Sauv-Autom-* 
#rm -r Ori-TerrainFinal_10_10_10
#mm3d Campari OIS.*tif Abs TerrainFinal_10_10_10 GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=100 > monlog_aerofinale_iter1.txt
#rm -r Tmp-MM-Dir/Ori--Sauv-Autom-* 
#rm -r Ori-TerrainFinal_10_10_10_AllFree
#mm3d Campari OIS.*tif TerrainFinal_10_10_10 TerrainFinal_10_10_10_AllFree GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=10 AllFree=true > monlog_aerofinale_iter2.txt
#rm -r Tmp-MM-Dir/Ori--Sauv-Autom-* 
#rm -r Ori-TerrainFinal_10_10_0.5_AllFree
#mm3d Campari OIS.*tif TerrainFinal_10_10_10_AllFree TerrainFinal_10_10_0.5_AllFree GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=0.5 AllFree=true RapTxt=RapportResidus.txt > monlog_aerofinale_iter3.txt
#${repertoire_scripts}/AnalyseRapportMicMac.LINUX AnalyseRapportResidusMICMAC RapportResidus.txt --export_ogr_appuis_mesure PtsAppuiMesure.geojson --export_ogr_appuis_calcul PtsAppuiCalcul.geojson --export_ogr_residus_appuis VecteursResidusAppui.geojson
#mm3d Malt Ortho OIS.*tif TerrainFinal_10_10_0.5_AllFree MasqImGlob=filtre.tif NbVI=2 UseTA=0 NbProc=6 DirMEC=MEC-Malt-Final
#mm3d Tawny Ortho-MEC-Malt-Final/ RadiomEgal=false
#cd MEC-Malt-Final/
#mm3d GrShade Z_Num7_DeZoom2_STD-MALT.tif
#mm3d GrShade Z_Num8_DeZoom2_STD-MALT.tif
#cd ..
#python /home/adminlocal/Partage/HIATUS-1/code-hiatus/complete_tfw_micmac.py --input_micmac_folder=/home/adminlocal/Partage/HIATUS-4/sites/strasbourg/data/1969_3815-0041 --input_config=Final
#python /home/adminlocal/Partage/HIATUS-1/code-hiatus/convert_ZnumMax2MNS.py --input_micmac_folder=/home/adminlocal/Partage/HIATUS-4/sites/strasbourg/data/1969_3815-0041 --input_config=Final
cd /mnt/data/HIATUS/sites/strasbourg/data/
