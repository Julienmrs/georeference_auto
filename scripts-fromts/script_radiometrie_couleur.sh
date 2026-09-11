mkdir tempradiom
cd tempradiom
sh ../../bash_a_lancer_egalisationradiometrique_serveur_couleur.sh ../Ortho-MEC-Malt-Final /mnt/data/HIATUS/code-hiatus
rm -r 1 2 3
cd ../Ortho-MEC-Malt-Final
mv ../tempradiom/ini/corr .
mkdir brut
mv Ort_*tif brut
mv Orthopho*.tif brut
cp Orthopho*.tfw brut
mv corr/Ort_*.tif .
cd ..
mm3d Tawny Ortho-MEC-Malt-Final/ RadiomEgal=false
cd Ortho-MEC-Malt-Final
mv Ort_*.tif corr
mv Orthopho*.tif corr
cp Orthopho*.tfw corr
mv brut/Ort_*tif .

