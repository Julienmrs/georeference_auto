#cd /mnt/data/HIATUS/sites/strasbourg/data/$1
repertoire_scripts="/host/Stage_Hiatus/scripts-fromts/code-hiatus"
nbcpus="64"
pasdallage="1000"
cd TraitementAPP
###################################################################
#Sauvegardons ce qui a deja ete fait avec le RANSAC terrain...
mkdir SauveRANSACterrain
cp resultpi SauveRANSACterrain/
mv resultpif SauveRANSACterrain/
mv resultpifreproj SauveRANSACterrain/
mv pts_bdortho.txt SauveRANSACterrain/
mv pts_orthomicmac_abs.txt SauveRANSACterrain/
mv pts_bdortho.geojson SauveRANSACterrain/
mv pts_orthomicmac_abs.geojson SauveRANSACterrain/
mv pts3D_bdortho.txt SauveRANSACterrain/
mv pts3D_orthomicmac_abs.txt SauveRANSACterrain/
mv pts3D_bdortho_net.txt SauveRANSACterrain/
mv pts3D_orthomicmac_abs_net.txt SauveRANSACterrain/
mv *.pts2d SauveRANSACterrain/
mv ../MesuresAppuis-S2D.xml SauveRANSACterrain/
mv ../MesuresAppuis-S3D.xml SauveRANSACterrain/
mv ../appuis.xml SauveRANSACterrain/
mv  ../id_appuis.txt  SauveRANSACterrain/

###################################################################
mv resultpi resultpt
${repertoire_scripts}/HIATUS Reproj resultpt bidon bidon Orthophotomosaic_Tile_0_0.ori Orthophotomosaic_Tile_0_0.ori resultpi
${repertoire_scripts}/RANSAC resultpi resultpif --taille_case 5000 > /dev/null
#On reprojette en terrain
${repertoire_scripts}/HIATUS ReprojTerrain resultpif Orthophotomosaic_Tile_0_0.ori Orthophotomosaic_Tile_0_0.ori resultpifreproj
#On va aller chercher les z associe a ces points
${repertoire_scripts}/HIATUS ExportAsTxt resultpifreproj pts_bdortho.txt pts_orthomicmac_abs.txt
${repertoire_scripts}/HIATUS ExportAsGJson resultpifreproj pts_bdortho.geojson pts_orthomicmac_abs.geojson


#On aborde maintenant la partie avec MNS...
ls ../metadata/mns/*.HDR ../metadata/mns/*.hdr > liste_mns_bdortho.txt
for i in `cat liste_mns_bdortho.txt` ; do ${repertoire_scripts}/convert_ori.LINUX hdr2ori ${i} ; done
ls ../metadata/mns/*.TIF ../metadata/mns/*.tif > liste_mns_bdortho.txt
#Creation de la liste des MNS MICMAC a utiliser
ls ../MEC-Malt-Abs/Z_Num9*Tile.tfw > liste_mnsmicmac.txt
for i in `cat liste_mnsmicmac.txt` ; do ${repertoire_scripts}/convert_ori.LINUX tfw2ori ${i} ; done
ls ../MEC-Malt-Abs/Z_Num9*Tile.tif > liste_mnsmicmac.txt
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
#    ${repertoire_scripts}/mm3d-pour-reproj TestLib PersoALB Ori-Abs/Orientation-${i}.tif.xml TraitementAPP/pts3D_orthomicmac_abs_net.txt TraitementAPP/${i}.tif.pts2d
    mm3d TestLib PersoALB Ori-Abs/Orientation-${i}.tif.xml TraitementAPP/pts3D_orthomicmac_abs_net.txt TraitementAPP/${i}.tif.pts2d
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
#cd /mnt/data/HIATUS/sites/strasbourg/data/
