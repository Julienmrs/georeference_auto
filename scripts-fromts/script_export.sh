cd MEC-Malt-Final/
ls MNS*.tif > malsite
for i in `cat malsite` ; do gdaladdo -ro ${i} 8 16 ; done
rm malsite
cd ..
cd Ortho-MEC-Malt-Final/
for k in corr brut ; do 
cd ${k}
ls Orthophot*Tile*.tif > malsite
for i in `cat malsite` ; do gdaladdo -r average -ro ${i} 8 16 ; done
rm malsite
gdalbuildvrt Orthophotomosaic.vrt Orthoph*Tile*tif
cd ..
done
cd ..
rm -r MEC-Malt-Final/Tmp-MM-Dir/
rm -r Ortho-MEC-Malt-Final/Tmp-MM-Dir/

