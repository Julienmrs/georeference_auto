rm liste_chantiers.txt liste_cliches.txt
ls -d * > liste_chantiers.txt
for chantier in `cat liste_chantiers.txt`; do
    cd ${chantier}
    ls *.jp2 > liste_cliches.txt
    echo -n "" > liste_cliches2.txt
    for cliche in `cat liste_cliches.txt`; do
	nomcliche=${cliche%.*} ;
	echo ${nomcliche} >> liste_cliches2.txt
    done
    mv liste_cliches2.txt liste_cliches.txt
    cd ..
done