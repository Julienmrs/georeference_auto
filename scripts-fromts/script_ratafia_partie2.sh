date >> journal.txt
echo "Malt Abs-Ratafia" >> journal.txt
mm3d Malt Ortho OIS.*tif Abs-Ratafia-AllFree MasqImGlob=filtre.tif NbVI=2 UseTA=0 NbProc=30 DirMEC=MEC-Malt-Abs-Ratafia
date >> journal.txt
echo "Tawny Abs-Ratafia" >> journal.txt
mm3d Tawny Ortho-MEC-Malt-Abs-Ratafia/ RadiomEgal=false
date >> journal.txt
echo "Z_Num > MNS + tfw" >> journal.txt
python /mnt/data/HIATUS/code-hiatus/complete_tfw_micmac.py --input_micmac_folder ./ --input_config Abs-Ratafia
python /mnt/data/HIATUS/code-hiatus/convert_ZnumMax2MNS_ALB.py --input_micmac_folder ./ --input_config Abs-Ratafia  --exe_mm3d /mnt/data/HIATUS/code-hiatus/mm3d-pour-reproj
ls MEC-Malt-Abs-Ratafia/MNS*.tif > listemnstmp ; for i in `cat listemnstmp` ; do gdal_translate ${i} mnstmp.tif ; mv mnstmp.tif ${i} ; done
date >> journal.txt

echo "Renommage" >> journal.txt

mv Ori-Abs Ori-Abs-Ini
mv MEC-Malt-Abs MEC-Malt-Abs-Ini
mv Ortho-MEC-Malt-Abs Ortho-MEC-Malt-Abs-Ini

mv Ori-Abs-Ratafia-AllFree Ori-Abs
mv MEC-Malt-Abs-Ratafia MEC-Malt-Abs
mv Ortho-MEC-Malt-Abs-Ratafia Ortho-MEC-Malt-Abs

date >> journal.txt
