mkdir tempradiom
cd tempradiom
sh /host/Stage_Hiatus/scripts-fromts/bash_a_lancer_egalisationradiometrique_serveur_panchro_bis.sh ../Ortho-MEC-Malt-$1 /host/Stage_Hiatus/scripts-fromts/code-hiatus
#sh ../../bash_a_lancer_egalisationradiometrique_serveur_panchro.sh ../Ortho-MEC-Malt-Final /mnt/data/HIATUS/code-hiatus
cd ../Ortho-MEC-Malt-$1
mv ../tempradiom/ini/corr .
mkdir brut
mv Ort_*tif brut
mv Orthopho*.tif brut
cp Orthopho*.tfw brut
mv corr/Ort_*.tif .
cd ..
mm3d Tawny Ortho-MEC-Malt-$1/ RadiomEgal=false
cd Ortho-MEC-Malt-$1
mv Ort_*.tif corr
mv Orthopho*.tif corr
cp Orthopho*.tfw corr
mv brut/Ort_*tif .

