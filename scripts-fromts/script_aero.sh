#mm3d Campari OIS.*tif Abs TerrainFinal_10_10_10 GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=100 > monlog_aerofinale_iter1.txt
mm3d Campari OIS.*tif Abs TerrainFinal_10_10_10 GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=10 > monlog_aerofinale_iter1.txt
mm3d Campari OIS.*tif TerrainFinal_10_10_10 TerrainFinal_10_10_10_AllFree GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=10 AllFree=true > monlog_aerofinale_iter2.txt
mm3d Campari OIS.*tif TerrainFinal_10_10_10_AllFree TerrainFinal_10_10_0.5_AllFree GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=0.5 AllFree=true RapTxt=RapportResidus.txt > monlog_aerofinale_iter3.txt
mkdir iter0
mv MesuresAppuis-S*.xml iter0/
mv appuis.xml iter0/
mv id_appuis.txt iter0/
mv RapportResidus.txt iter0/
mv monlog_aero* iter0/
../../../../code-hiatus/AnalyseRapportMicMac.LINUX AnalyseRapportResidusMICMAC iter0/RapportResidus.txt --export_ogr_appuis_mesure PtsAppuiMesure.geojson --export_ogr_appuis_calcul PtsAppuiCalcul.geojson --export_ogr_residus_appuis VecteursResidusAppui.geojson --coeff_filtrage 3 --reexport_pts_pour_aeromicmac
mm3d Campari OIS.*tif TerrainFinal_10_10_10_AllFree TerrainFinal_10_10_0.5_AllFree GCP=[appuis.xml,10,MesuresAppuis-S2D.xml,10]  SigmaTieP=0.5 AllFree=true RapTxt=RapportResidus.txt > monlog_aerofinale_iter3.txt
../../../../code-hiatus/AnalyseRapportMicMac.LINUX AnalyseRapportResidusMICMAC RapportResidus.txt --export_ogr_appuis_mesure PtsAppuiMesure.geojson --export_ogr_appuis_calcul PtsAppuiCalcul.geojson --export_ogr_residus_appuis VecteursResidusAppui.geojson 

