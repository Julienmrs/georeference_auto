repertoire_Ortho_MEC_Malt=$1
repertoire_exe=$2

ls ${repertoire_Ortho_MEC_Malt}/Ort_*.tif > liste_cliches.txt


#Nettoyage du fichier : on passe de "rep/Ort_nomcliche.tif" a "nomcliche"
echo -n "" > liste_cliches.txttmp 
for i in `cat liste_cliches.txt` ; do  
fichier=$(basename ${i}); 
fichiersansext=`echo ${fichier}|cut -d"." -f1`
fichier=`echo ${fichiersansext}|cut -b 5- ` ; 
echo ${fichier} >> liste_cliches.txttmp 
done
mv liste_cliches.txttmp liste_cliches.txt

echo -n "" > monbash 
for i in `cat liste_cliches.txt ` ; do 
echo ${i} ; 
echo "${repertoire_exe}/Ech_noif.LINUX SousEchMoy ${repertoire_Ortho_MEC_Malt}/Ort_${i}.tif Ort_${i}.tif  10 ;  \
${repertoire_exe}/convert_ori.LINUX tfw2ori ${repertoire_Ortho_MEC_Malt}/Ort_${i}.tfw Ort_${i}.ini.ori ; \
${repertoire_exe}/HIATUS.LINUX SousechOri Ort_${i}.ini.ori 10 Ort_${i}.ori ; \
${repertoire_exe}/Ech_noif.LINUX SousEch ${repertoire_Ortho_MEC_Malt}/PC_${i}.tif PC_${i}.tif 10 ;  \
${repertoire_exe}/Ech_noif.LINUX Erod  PC_${i}.tif 3 tmp_${i}.rle ; \
${repertoire_exe}/Ech_noif.LINUX AppliqueMargeBord tmp_${i}.rle 1 tmp_${i}.rle 255 ; \
${repertoire_exe}/Ech_noif.LINUX Dilat tmp_${i}.rle 5 Incid_${i}.tif ; \
rm tmp_${i}.rle ;
" >> monbash
#Ech_noif Dilat tmp.rle 5 ssech10/Incid_${i}.tif ; 
done
${repertoire_exe}/Bash2Make.LINUX monbash monmake 
make -f monmake -j 20


#SI PLUSIEURS CANAUX
mkdir ini
mv Ort_*tif ini/
cp Ort_* ini/

for b in 1 2 3; do mkdir ${b} ; for i in `cat liste_cliches.txt ` ; do gdal_translate -b ${b} ini/Ort_${i}.tif ${b}/Ort_${i}.tif  ; done ; cp ini/*.ori ${b} ; done



for b in 1 2 3 ; do 
cd ${b}
cp ../liste_cliches.txt .

#echo -n "/media/Data2/transfert_rks/29/testhotspot/build/Egalise " > monbash

echo -n "${repertoire_exe}/Egalise.LINUX " > monbash
for i in `cat liste_cliches.txt ` ; do echo -n "${i}.tif "  >> monbash ; done
echo "--reference:moyenne --fusion:moyenne --modele:additif --ssechfinal 1 --noegal" >> monbash
echo "mv big_image.tif big_image.noegal_moyenne.tif" >> monbash
echo "" >> monbash
echo -n "${repertoire_exe}/Egalise.LINUX " >> monbash
for i in `cat liste_cliches.txt ` ; do echo -n "${i}.tif "  >> monbash ; done
echo "--reference:moyenne --fusion:voronoi --modele:additif --ssechfinal 1 --noegal" >> monbash
echo "mv big_image.tif big_image.noegal_voronoi.tif" >> monbash
echo "" >> monbash
echo -n "${repertoire_exe}/Egalise.LINUX " >> monbash
for i in `cat liste_cliches.txt ` ; do echo -n "${i}.tif "  >> monbash ; done
echo "--reference:moyenne --fusion:moyenne --modele:additif --ssechfinal 1 --pas 200" >> monbash
echo "mv big_image.tif big_image.additif_moyenne.tif" >> monbash
echo "" >> monbash
echo -n "${repertoire_exe}/Egalise.LINUX " >> monbash
for i in `cat liste_cliches.txt ` ; do echo -n "${i}.tif "  >> monbash ; done
echo "--reference:moyenne --fusion:voronoi --modele:additif --ssechfinal 1 --pas 200" >> monbash
echo "mv big_image.tif big_image.additif_voronoi.tif" >> monbash
echo "" >> monbash

sh ./monbash	
${repertoire_exe}/Ech_noif.LINUX Int2Char big_image.noegal_voronoi.tif 0 255 big_image.noegal_voronoi.tif
${repertoire_exe}/Ech_noif.LINUX Int2Char big_image.noegal_moyenne.tif 0 255 big_image.noegal_moyenne.tif

rm Solution_*

${repertoire_exe}/Ech_noif.LINUX Bool big_image.noegal_moyenne.tif big_image.mask.tif
echo -n "${repertoire_exe}/Pleiades.LINUX MNSMICMAC \$1 \$2 " > bash_applique_walis_tmp
${repertoire_exe}/Ech_noif.LINUX Walis big_image.noegal_moyenne.tif big_image.mask.tif big_image.additif_moyenne.tif big_image.mask.tif big_image.walis.tif >> bash_applique_walis_tmp
mv log.txt log_walis.txt
${repertoire_exe}/Ech_noif.LINUX Int2Char big_image.walis.tif 0 255 big_image.walis.tif

cd ..

done

${repertoire_exe}/Ech_noif.LINUX AssembleCanaux 1/big_image.noegal_voronoi.tif 2/big_image.noegal_voronoi.tif 3/big_image.noegal_voronoi.tif  ini/big_image.noegal_voronoi.tif 
${repertoire_exe}/Ech_noif.LINUX AssembleCanaux 1/big_image.noegal_moyenne.tif 2/big_image.noegal_moyenne.tif 3/big_image.noegal_moyenne.tif  ini/big_image.noegal_moyenne.tif 
${repertoire_exe}/Ech_noif.LINUX AssembleCanaux 1/big_image.additif_voronoi.tif 2/big_image.additif_voronoi.tif 3/big_image.additif_voronoi.tif  ini/big_image.additif_voronoi.tif 
${repertoire_exe}/Ech_noif.LINUX AssembleCanaux 1/big_image.additif_moyenne.tif 2/big_image.additif_moyenne.tif 3/big_image.additif_moyenne.tif  ini/big_image.additif_moyenne.tif 
${repertoire_exe}/Ech_noif.LINUX AssembleCanaux 1/big_image.walis.tif 2/big_image.walis.tif 3/big_image.walis.tif ini/big_image.walis.tif 
${repertoire_exe}/Ech_noif.LINUX Format ini/big_image.walis.tif ini/big_image.walis.tif 
${repertoire_exe}/Ech_noif.LINUX Format ini/big_image.noegal_voronoi.tif ini/big_image.noegal_voronoi.tif 
${repertoire_exe}/Ech_noif.LINUX Format ini/big_image.noegal_moyenne.tif ini/big_image.noegal_moyenne.tif 
cp 1/big_image.mask.tif ini/big_image.mask.tif
cp 1/big_image.ori ini/big_image.ori
cp liste_cliches.txt ini

cd ini



#mkdir ../${repertoire_Ortho_MEC_Malt}/corr
mkdir corr
echo -n "" > monbash ;
for i in `cat liste_cliches.txt ` ; do 
echo ${i} ; 
echo -n "${repertoire_exe}/Decoupage_mono.LINUX Fsuperposable Ort_${i}.ori big_image.ori big_image.additif_moyenne.tif tmp_${i}.tif ; \
${repertoire_exe}/Pleiades.LINUX CalculMNE Ort_${i}.tif tmp_${i}.tif tmp_${i}.tif  ;  \
${repertoire_exe}/Ech_noif.LINUX Gaussf tmp_${i}.tif tmp_${i}.tif 5 4 ; \
${repertoire_exe}/Decoupage_mono.LINUX Fsuperposable Ort_${i}.ini.ori Ort_${i}.ori tmp_${i}.tif tmp_${i}.tif ;  \
${repertoire_exe}/Pleiades.LINUX CalculMNE ../${repertoire_Ortho_MEC_Malt}/Ort_${i}.tif tmp_${i}.tif tmp_${i}.tif ; " >> monbash
for b in 1 2 3 ; do  
echo -n "gdal_translate -b ${b} tmp_${i}.tif tmp${b}_${i}.tif ; \
sh ../${b}/bash_applique_walis_tmp tmp${b}_${i}.tif tmp${b}_${i}.tif ; " >> monbash
done ; 
echo -n "${repertoire_exe}/Ech_noif.LINUX AssembleCanaux  tmp1_${i}.tif tmp2_${i}.tif tmp3_${i}.tif tmp_${i}.tif  ; " >> monbash
for b in 1 2 3 ; do echo -n "rm tmp${b}_${i}.tif ; " >> monbash ; done ; 
echo "${repertoire_exe}/Ech_noif.LINUX Int2Char tmp_${i}.tif 0 255 corr/Ort_${i}.tif ; \
rm tmp_${i}.tif ; " >> monbash
done
${repertoire_exe}/Bash2Make.LINUX monbash monmake 
make -f monmake -j 20

cd ..
