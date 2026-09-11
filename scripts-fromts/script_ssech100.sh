#cd /mnt/data/HIATUS/sites/strasbourg/data/$1
#echo $1
#cd /mnt/data/HIATUS/sites/strasbourg/data/1967_3815-0141
repertoire_scripts="/host/Stage_Hiatus/scripts-fromts/code-hiatus"
nbcpus="3"
pasdallage="1000"
mkdir TraitementAPPssech100
cd TraitementAPPssech100
ls ../Ortho-MEC-Malt-Abs/Orthophotomosaic_Tile_*.tif > liste_tile.txt
mkdir dallage
#${repertoire_scripts}/convert_ori.LINUX tfw2ori ../Ortho-MEC-Malt-Abs/Orthophotomosaic.tfw Orthophotomosaic.ori #Finalement non...
#${repertoire_scripts}/HIATUS.LINUX SousechOri ${nomdalle}.ori 100 ${nomdalle}.ssech100.ori
#On commence par daller les differentes orthoimages deja generees
for i in `cat liste_tile.txt` ; do
fichier=$(basename ${i})
nomdalle=${fichier%.*}
ln -s ../Ortho-MEC-Malt-Abs/${nomdalle}.tif .
${repertoire_scripts}/convert_ori.LINUX tfw2ori ../Ortho-MEC-Malt-Abs/${nomdalle}.tfw ${nomdalle}.ori
${repertoire_scripts}/HIATUS.LINUX SousechOri ${nomdalle}.ori 10 ${nomdalle}.ssech100.ori
echo "${nomdalle}.tif" > listetmp
cat listetmp
${repertoire_scripts}/Decoupage.LINUX ${nomdalle}.ssech100.ori listetmp ${nomdalle}.ssech100.tif 
rm listetmp
${repertoire_scripts}/Split.LINUX ${nomdalle}.ssech100.tif ${pasdallage} ${pasdallage} dallage/${nomdalle}
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
ls ../metadata/ortho/*.TFW ../metadata/ortho/*.tfw > liste_bdortho.txt
for i in `cat liste_bdortho.txt` ; do 
${repertoire_scripts}/convert_ori.LINUX tfw2ori ${i} 
done
ls ../metadata/ortho/*.TIF ../metadata/ortho/*.tif > liste_bdortho.txt
echo -n "" > bashtmp
for i in `cat liste_dalles.txt` ; do 
#On cree une dalle d ortho superposable (a terme rajouter des marges ?)
echo -n "${repertoire_scripts}/Decoupage.LINUX dallage/${i}.ori liste_bdortho.txt dallage/bdortho_${i}.tif > /dev/null ; " >> bashtmp ;
echo -n "${repertoire_scripts}/Ech_noif.LINUX Format dallage/bdortho_${i}.tif dallage/bdortho_${i}.tif ; " >> bashtmp ;
#Detection des points d interet
echo -n "${repertoire_scripts}/MethodeAubry.LINUX dallage/bdortho_${i}.tif dallage/bdortho_${i}.kaub --maxlocaux --Mu ${repertoire_scripts}/MuAubry.tif --SigmaInv ${repertoire_scripts}/SigmaInvAubry.tif > /dev/null ; " >> bashtmp ;
echo -n "${repertoire_scripts}/FiltrageMasqueDilat.LINUX --image dallage/bdortho_${i}.tif --rayon 10 --kp:bin dallage/bdortho_${i}.kaub --out dallage/bdortho_${i}.kaub > /dev/null ; " >> bashtmp ;
#Mise en correspondance 
echo -n "${repertoire_scripts}/MethodeAubryAppariement.LINUX Points:Image dallage/bdortho_${i}.kaub dallage/${i}.tif dallage/${i}.resultpi --Mu ${repertoire_scripts}/MuAubry.tif --SigmaInv ${repertoire_scripts}/SigmaInvAubry.tif > /dev/null ; " >> bashtmp 
#On supprime les points situes dans les zones "noires"
echo -n "${repertoire_scripts}/HIATUS NettoyageResultZoneNoire  dallage/${i}.resultpi dallage/${i}.tif dallage/${i}.resultpi > /dev/null ; " >> bashtmp 
#On reprojette les coordonnees dans un referentiel commun (coordonnees images dans l ori de Orthophotomosaic) --> A faire en mieux
echo "${repertoire_scripts}/HIATUS Reproj dallage/${i}.resultpi dallage/bdortho_${i}.ori dallage/${i}.ori Orthophotomosaic.ori Orthophotomosaic.ori dallage/${i}.resultpireproj " >> bashtmp
done
${repertoire_scripts}/Bash2Make.LINUX bashtmp monmaketmp
make -k -f monmaketmp -j ${nbcpus};
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

