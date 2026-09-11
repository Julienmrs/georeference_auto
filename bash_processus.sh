timestart=$SECONDS

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $ROOT_DIR/Echantillon_jp2_mars2025/

# #On liste les differents repertoires 
rm liste_chantiers.txt liste_cliches.txt
ls -d * > liste_chantiers.txt
for chantier in `cat liste_chantiers.txt`; do
    cd ${chantier}
    ls *.tif > liste_cliches.txt
    echo -n "" > liste_cliches2.txt
    for cliche in `cat liste_cliches.txt`; do
        nomcliche=${cliche%.*} ;
        echo ${nomcliche} >> liste_cliches2.txt
    done
    mv liste_cliches2.txt liste_cliches.txt
    cd ..
done
    
ls */*.tif > liste_cliches.txt
#On lance le processus permettant de recuperer leur metadonnees approchees et d'initialiser la transf
. $ROOT_DIR/bash_initialisation.sh
echo "Temps d'execution : $(( SECONDS - timestart )) secondes"
timestart2=$SECONDS

#Il va maintenant falloir recuperer la BDORtho pour chaque patient
#On commence par calculer l'emprise globale de la zone (en prenant une marge de 500m)
for chantier in `cat liste_chantiers.txt`; do
    cd ${chantier}
    #On a deja liste les differents cliches en presence
    python3 $ROOT_DIR/OutilsLB/EmpriseDesEmprises.py liste_cliches.txt EmpriseGlobale.txt 500
    cd ..
done
echo "Calcul emprise : $(( SECONDS - timestart2 )) secondes"
timestart3=$SECONDS
##On va maintenant pouvoir telecharger la BDOrtho 
resolution_souhaitee=10
for chantier in `cat liste_chantiers.txt`; do
    echo ${chantier}
    cd ${chantier}
    echo -n "gdal_translate   -oo ZOOM_LEVEL=9 --config GDAL_HTTP_MAX_RETRY 30 --config GDAL_HTTP_RETRY_DELAY 15 -of GTiff WMS:\"https://data.geopf.fr/wms-r?LAYERS=HR.ORTHOIMAGERY.ORTHOPHOTOS&FORMAT=image/geotiff&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&STYLES=&CRS=EPSG:2154\" -projwin " > bash_download_gdal.sh
    for i in `cat EmpriseGlobale.txt`; do 
	echo -n "${i} " >> bash_download_gdal.sh
    done
    echo "-tr ${resolution_souhaitee} ${resolution_souhaitee} -r average BDOrtho.tif" >> bash_download_gdal.sh
    sh bash_download_gdal.sh
    cd ..
done

echo "Téléchargement BDOrtho : $(( SECONDS - timestart3 )) secondes" >> ../temps.txt

# #Pour les MNT, on va plutot travailler a partir de la BDAlti a 25m que l'on aura prealablement stockee quelque part
# adresse_MNT="$ROOT_DIR/OutilsLB/BDAlti/BDAlti_FranceEntiere_0.tif"
# for chantier in `cat liste_chantiers.txt`; do
#     echo ${chantier}
#     cd ${chantier}
#     echo -n "gdal_translate ${adresse_MNT} -projwin " > bash_getMNT.sh
#     for i in `cat EmpriseGlobale.txt`; do 
# 	echo -n "${i} " >> bash_getMNT.sh
#     done
#     echo "-tr ${resolution_souhaitee} ${resolution_souhaitee} -r bilinear MNT.tif" >> bash_getMNT.sh
#     sh bash_getMNT.sh
#     listgeo -tfw MNT.tif
#     cd ..
# done

#On va maintenant pouvoir telecharger la BDOrtho 
#gdal_translate -of GTiff WMS:"https://data.geopf.fr/wms-r?LAYERS=HR.ORTHOIMAGERY.ORTHOPHOTOS&FORMAT=image/geotiff&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&STYLES=&CRS=EPSG:2154" -projwin 893959.9997510061 6758620.003909538 904949.9972601589 6749720.000087059  -tr 1 1  -r average im2.tif
