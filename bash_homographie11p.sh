#for chantier in `cat liste_chantiers.txt`; do
# for chantier in ./* ; do
#     cd ${chantier}
#     echo ${chantier}
ROOT="/home/jmeresse/test_chemin_2/OutilsLB/"
cd Echantillon_jp2_mars2025/Lure/travail_ssech5/
adresseMNT="/home/jmeresse/test_chemin_2/OutilsLB/MNT.tif"
#adresseMNT="MNTtmp.tif"
for cliche in `cat ../liste_cliches.txt `; do 
	echo ${cliche}
	#gdalwarp -overwrite -cutline ${cliche}.shp -r average -crop_to_cutline -tr 5 5 -overwrite ../MNT.tif MNTtmp.tif ; listgeo -tfw MNTtmp.tif
	$ROOT/LB.LINUX ScindeResult ${cliche}.BDOrtho.-.${cliche}.resultspgf ${cliche}.ptsref.txt ${cliche}.ptsarec.txt
	$ROOT/LB.LINUX ImageToTerrain ${cliche}.ptsref.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsrefEN.txt
	$ROOT/LB.LINUX ImageToTerrain ${cliche}.ptsarec.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsarecEN.txt
	$ROOT/LB.LINUX GetZ ${cliche}.ptsrefEN.txt ${adresseMNT} ${cliche}.ptsrefENh.txt
	$ROOT/LB.LINUX TerrainToImage ${cliche}.ptsarecEN.txt ../${cliche}.tfw ${cliche}.ptsarecimini.txt
	$ROOT/LB.LINUX CalculHom11p ${cliche}.ptsarecimini.txt ${cliche}.ptsrefENh.txt  
	mv modele_h11.txt ${cliche}.modele_h11.spg.txt ; $ROOT/LB.LINUX WarpHom11p ${cliche}.modele_h11.spg.txt ${adresseMNT} ../${cliche}.tif ${cliche}.h11spg.tif  ; gdal_edit.py -a_srs EPSG:2154 ${cliche}.h11spg.tif 

	$ROOT/LB.LINUX ScindeResult ${cliche}.BDOrtho.-.${cliche}.resultpif ${cliche}.ptsref.txt ${cliche}.ptsarec.txt
	$ROOT/LB.LINUX ImageToTerrain ${cliche}.ptsref.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsrefEN.txt
	$ROOT/LB.LINUX ImageToTerrain ${cliche}.ptsarec.txt ${cliche}.BDOrtho.tfw ${cliche}.ptsarecEN.txt
	$ROOT/LB.LINUX GetZ ${cliche}.ptsrefEN.txt ${adresseMNT} ${cliche}.ptsrefENh.txt
	$ROOT/LB.LINUX TerrainToImage ${cliche}.ptsarecEN.txt ../${cliche}.tfw ${cliche}.ptsarecimini.txt
	$ROOT/LB.LINUX CalculHom11p ${cliche}.ptsarecimini.txt ${cliche}.ptsrefENh.txt  
	mv modele_h11.txt ${cliche}.modele_h11.kaub.txt ; $ROOT/LB.LINUX WarpHom11p ${cliche}.modele_h11.kaub.txt ${adresseMNT} ../${cliche}.tif ${cliche}.h11kaub.tif ; gdal_edit.py -a_srs EPSG:2154 ${cliche}.h11kaub.tif 
done;
