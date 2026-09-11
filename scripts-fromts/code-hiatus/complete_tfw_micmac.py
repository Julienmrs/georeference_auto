#! /usr/bin/env python
# -*- coding: iso-8859-1 -*-

import os
import argparse
import shutil

parser = argparse.ArgumentParser(description='Generation des metadonnees d un site HIATUS')

# GENERAL PARAMETER
parser.add_argument('--input_micmac_folder', default='/home/adminlocal/Partage/HIATUS-1/sites/sablesdolonne/data/1982_IPLI13_Nord', help='Dossier racine MicMac')
parser.add_argument('--input_config', default='Final', help='Dossier racine')
parser.add_argument('--exe_mm3d', default='/mnt/data/HIATUS/code-hiatus/mm3d-pour-reproj', help='Adresse micmac hiatus')
args = parser.parse_args()


#à partir d'une liste d'éléments, renvoie une sous-liste de tous les éléments qui contiennent une liste de pattern  
def filter_list_pattern_in(list_to_filter, list_pattern_in): 
    return [str for str in list_to_filter if
             all(subin in str for subin in list_pattern_in)] 

#à partir d'une liste d'éléments, renvoie une sous-liste de tous les éléments qui contiennent PAS une liste de pattern    
def filter_list_pattern_out(list_to_filter, list_pattern_out): 
    return [subout for subout in list_to_filter if not any(ignore in subout for ignore in list_pattern_out)]

#renvoie la liste de tous les fichiers d'un dossier qui contiennent une liste de pattern et ne contiennent pas une autre liste de pattern
def get_list_patterninout(input_folder, list_PatternIn, list_PatternOut):
	list_In=[]
	list_Out = []
	list_File = os.listdir(input_folder)
	list_In = filter_list_pattern_in(list_File, list_PatternIn)
	list_Out = filter_list_pattern_out(list_In, list_PatternOut)
	return list_Out

def write_tileTFW(list_tile, str_fileTFWglob, str_radicalTile, int_nbpix, str_config, str_dir):
	#lecture du TFW flobal	
	print('Creation des Tile TFW pour ' + str_fileTFWglob)
	listLineTFW = []
	str_fileTFW = input_micmac_folder+'/'+ str_dir + input_config + '/' + str_fileTFWglob
	if(not(os.path.exists(str_fileTFW))):
		return

	fileTFW = open(str_fileTFW, "r")

	for ligne in fileTFW:
		listLineTFW.append(float(ligne))
		#print(float(ligne))
	fileTFW.close()

	print(listLineTFW)

	#pour chaque Tile
	if not list_tile:
 		print('Pas de Tile pour '+str_fileTFWglob.split('.tfw')[0])
	else:
		for tile in list_tile:
			print(tile)
			#str_radicalTile = str_fileTFWglob.split('.tfw')[0] +'_Tile_' (pas les memes regles pour les differents produits)
			inum =  float(((tile.split(str_radicalTile)[-1]).split('.tif')[0]).split('_')[0]) 
			jnum = float(((tile.split(str_radicalTile)[-1]).split('.tif')[0]).split('_')[-1])
			Xtfw = listLineTFW[4] + int(int_nbpix)*inum*listLineTFW[0]
			Ytfw = listLineTFW[5] - int(int_nbpix)*jnum*listLineTFW[0]
			str_fileTFWExport = input_micmac_folder+'/'+ str_dir + input_config + '/' + str_radicalTile  + str(int(inum)) + '_' + str(int(jnum)) + '.tfw'
			print(listLineTFW[0], listLineTFW[1], listLineTFW[2], listLineTFW[3], str(Xtfw), str(Ytfw))
			fileTFWExport = open(str_fileTFWExport, "w")
			fileTFWExport.write(str(listLineTFW[0])+'\n')
			fileTFWExport.write(str(listLineTFW[1])+'\n')
			fileTFWExport.write(str(listLineTFW[2])+'\n')
			fileTFWExport.write(str(listLineTFW[3])+'\n')
			fileTFWExport.write(str(Xtfw)+'\n')
			fileTFWExport.write(str(Ytfw))
	return None


#-----------------------------------------------------
if __name__ == "__main__":
	#tic = time.time()
	print(args)
	#print(time.strftime('%d/%m/%y %H:%M',time.localtime()))

	input_micmac_folder = (args.input_micmac_folder).rstrip('/')
	input_config = (args.input_config).rstrip('/')

	#Suite a des problemes sur le georeferencement des MNS, on remplace la suite par ce module appelant MicMac modifie
        exe_mm3d = args.exe_mm3d

	radical_ZNum9=input_micmac_folder+'/MEC-Malt-'+input_config+'/Z_Num9_DeZoom2_STD-MALT'
	radical_ZNum8=input_micmac_folder+'/MEC-Malt-'+input_config+'/Z_Num8_DeZoom2_STD-MALT'
	radical_ZNum7=input_micmac_folder+'/MEC-Malt-'+input_config+'/Z_Num7_DeZoom2_STD-MALT'
	radical_ZNum7Shade=input_micmac_folder+'/MEC-Malt-'+input_config+'/Z_Num7_DeZoom2_STD-MALTShade'
	radical_ZNum8Shade=input_micmac_folder+'/MEC-Malt-'+input_config+'/Z_Num8_DeZoom2_STD-MALTShade'
	radical_Ortho=input_micmac_folder+'/Ortho-MEC-Malt-'+ input_config+'/Orthophotomosaic'
	
	strcommande=exe_mm3d +' TestLib PersoALB TfwFinaux '+radical_ZNum7
	print(strcommande)
	os.system(strcommande)
	strcommande=exe_mm3d +' TestLib PersoALB TfwFinaux '+radical_ZNum8
	print(strcommande)
	os.system(strcommande)
	strcommande=exe_mm3d +' TestLib PersoALB TfwFinaux '+radical_ZNum9
	print(strcommande)
	os.system(strcommande)
	shutil.copy(radical_ZNum7+'.tfw',radical_ZNum7Shade+'.tfw')
	strcommande=exe_mm3d +' TestLib PersoALB TfwFinaux '+radical_ZNum7Shade
	print(strcommande)
	os.system(strcommande)
	shutil.copy(radical_ZNum8+'.tfw',radical_ZNum8Shade+'.tfw')
	strcommande=exe_mm3d +' TestLib PersoALB TfwFinaux '+radical_ZNum8Shade
	print(strcommande)
	os.system(strcommande)
	strcommande=exe_mm3d +' TestLib PersoALB TfwFinaux '+radical_Ortho
	print(strcommande)
	os.system(strcommande)

	

	
	quit()
	print('Si on passe ici, il y a un probleme...')


	#Récupération des listes des fichiers à compléter pour une config MicMac
	#à gérer : if si les données ne sont pas tuilées si besoin (Shade ?)
	list_ZNum9Tile = get_list_patterninout(input_micmac_folder+'/MEC-Malt-'+ input_config, ['Z_Num9', '_Tile_', '.tif'], ['Shade', '.aux.xml'] )
	list_ZNum8Tile = get_list_patterninout(input_micmac_folder+'/MEC-Malt-'+ input_config, ['Z_Num8', '_Tile_', '.tif'], ['Shade', '.aux.xml'] )
	list_ZNum7Tile = get_list_patterninout(input_micmac_folder+'/MEC-Malt-'+ input_config, ['Z_Num7', '_Tile_', '.tif'], ['Shade', '.aux.xml'] )
	list_ZNum7ShadeTile  = get_list_patterninout(input_micmac_folder+'/MEC-Malt-'+ input_config, ['Z_Num7', '_Tile_', 'Shade', '.tif'], ['.aux.xml'] )
	list_ZNum8ShadeTile  = get_list_patterninout(input_micmac_folder+'/MEC-Malt-'+ input_config, ['Z_Num8', '_Tile_', 'Shade', '.tif'], ['.aux.xml'] )
	print(list_ZNum7ShadeTile) 


	list_OrthoTile = get_list_patterninout(input_micmac_folder+'/Ortho-MEC-Malt-'+ input_config, ['Orthophotomosaic', '_Tile_','.tif'], [] )
	#print('list_OrthoTile ', list_OrthoTile)	

	write_tileTFW(list_ZNum7ShadeTile, 'Z_Num7_DeZoom2_STD-MALT.tfw', 'Z_Num7_DeZoom2_STD-MALTShade_Tile_', 32768, input_config, 	'MEC-Malt-')
	write_tileTFW(list_ZNum8ShadeTile, 'Z_Num8_DeZoom2_STD-MALT.tfw', 'Z_Num8_DeZoom2_STD-MALTShade_Tile_', 32768, input_config, 'MEC-Malt-')
	write_tileTFW(list_ZNum7Tile, 'Z_Num7_DeZoom2_STD-MALT.tfw', 'Z_Num7_DeZoom2_STD-MALT_Tile_', 40448, input_config, 'MEC-Malt-')
#	write_tileTFW(list_ZNum8Tile, 'Z_Num8_DeZoom2_STD-MALT.tfw', 'Z_Num8_DeZoom2_STD-MALT_Tile_', 40448, input_config, 'MEC-Malt-')
	write_tileTFW(list_ZNum8Tile, 'Z_Num8_DeZoom2_STD-MALT.tfw', 'Z_Num8_DeZoom2_STD-MALT_Tile_', 28672, input_config, 'MEC-Malt-')
	write_tileTFW(list_ZNum9Tile, 'Z_Num9_DeZoom2_STD-MALT.tfw', 'Z_Num9_DeZoom2_STD-MALT_Tile_', 28672, input_config, 'MEC-Malt-')
	write_tileTFW(list_OrthoTile, 'Orthophotomosaic.tfw', 'Orthophotomosaic_Tile_', 20480, input_config, 'Ortho-MEC-Malt-')


	

