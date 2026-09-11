mm3d Malt Ortho OIS.*tif TerrainFinal_10_10_0.5_AllFree MasqImGlob=filtre.tif NbVI=2 UseTA=0 NbProc=30 DirMEC=MEC-Malt-Final
mm3d Tawny Ortho-MEC-Malt-Final/ RadiomEgal=false
cd MEC-Malt-Final
mm3d GrShade Z_Num7_DeZoom2_STD-MALT.tif
mm3d GrShade Z_Num8_DeZoom2_STD-MALT.tif
cd ..
python /mnt/data/HIATUS/code-hiatus/complete_tfw_micmac.py --input_micmac_folder ./ --input_config Final
# /mnt/data/HIATUS/code-hiatus/mm3d-pour-reproj TestLib PersoALB MNSMICMAC MEC-Malt-Final/Z_Num8_DeZoom2_STD-MALT.tif MEC-Malt-Final/MNS_Final_Num8_DeZoom2_STD-MALT.tif MEC-Malt-Final/Z_Num8_DeZoom2_STD-MALT.xml
#cp MEC-Malt-Final/Z_Num8_DeZoom2_STD-MALT.tfw MEC-Malt-Final/MNS_Final_Num8_DeZoom2_STD-MALT.tfw
python /mnt/data/HIATUS/code-hiatus/convert_ZnumMax2MNS_ALB.py --input_micmac_folder ./ --input_config Final  --exe_mm3d /mnt/data/HIATUS/code-hiatus/mm3d-pour-reproj

