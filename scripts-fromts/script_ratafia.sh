mm3d TestLib NO_AllOri2Im OIS.*tif
mm3d Ratafia OIS.*tif

mv Homol Homol-Ini
mv Homol-Ratafia Homol

mm3d Campari OIS.*tif Abs Abs-Ratafia 
mm3d Campari OIS.*tif Abs-Ratafia Abs-Ratafia-AllFree AllFree=true > monlog_aero

mm3d Malt Ortho OIS.*tif Abs-Ratafia-AllFree MasqImGlob=filtre.tif NbVI=2 UseTA=0 NbProc=30 DirMEC=MEC-Malt-Abs-Ratafia
mm3d Tawny Ortho-MEC-Malt-Abs-Ratafia/ RadiomEgal=false
python /mnt/data/HIATUS/code-hiatus/complete_tfw_micmac.py --input_micmac_folder ./ --input_config Abs-Ratafia
python /mnt/data/HIATUS/code-hiatus/convert_ZnumMax2MNS_ALB.py --input_micmac_folder ./ --input_config Abs-Ratafia  --exe_mm3d /mnt/data/HIATUS/code-hiatus/mm3d-pour-reproj

mv Ori-Abs Ori-Abs-Ini
mv MEC-Malt-Abs MEC-Malt-Abs-Ini
mv Ortho-MEC-Malt-Abs Ortho-MEC-Malt-Abs-Ini

mv Ori-Abs-Ratafia-AllFree Ori-Abs
mv MEC-Malt-Abs-Ratafia MEC-Malt-Abs
mv Ortho-MEC-Malt-Abs-Ratafia Ortho-MEC-Malt-Abs

