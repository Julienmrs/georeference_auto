#! /usr/bin/env python
# -*- coding: iso-8859-1 -*-
import os
import sys
import shutil
from lxml import etree
import argparse

parser = argparse.ArgumentParser(description='Generation des metadonnees d un site HIATUS')

# GENERAL PARAMETER
parser.add_argument('--input_micmac_folder', default='/home/adminlocal/Partage/HIATUS-1/sites/sablesdolonne/data/1982_IPLI13_Nord', help='Dossier racine MicMac')
parser.add_argument('--input_config', default='Abs', help='Dossier racine')
args = parser.parse_args()



#-----------------------------------------------------
if __name__ == "__main__":

	#tic = time.time()
	print(args)
	#print(time.strftime('%d/%m/%y %H:%M',time.localtime()))
	
	input_micmac_folder = (args.input_micmac_folder).rstrip('/')
	input_config = (args.input_config).rstrip('/')
	input_folder = input_micmac_folder+ '/MEC-Malt-' + input_config

	#se placer dans le rep
	os.chdir(input_folder)
	listFile = os.listdir(input_folder)
	print(input_folder)

	#inutile de tout convertir pour rien...
	traiter_uniquement_resolution_finale=1


	#On fait la liste des tif auxquels sont associes des _Tile
	numeromax=0
	liste_tif_a_ignorer=[]
	for file in listFile:

		if(file.split('Shade')[0]!=file):
			continue

		if(file[0:5] != 'Z_Num'):
			continue

		if(file.split('_Tile_')[0]!=file):
			liste_tif_a_ignorer.append(file.split('_Tile_')[0]+'.tif')
	
		numero=file.split('Z_Num')[1]
		numero=numero.split('_DeZoom')[0]
		numero=int(numero)
		numeromax=max(numero,numeromax)


	#print (liste_tif_a_ignorer)
	print('MNS_Num'+str(numero))

	for file in listFile:
		if(file[0:5] != 'Z_Num'):
			continue

		if(file.split('.')[-1]!='tif'):
			continue

		if(file in liste_tif_a_ignorer):
			continue

		if(traiter_uniquement_resolution_finale==1):
			numero=file.split('Z_Num')[1]
			numero=numero.split('_DeZoom')[0]
			numero=int(numero)
			if(numero!=numeromax):
				continue


		filexml=file.split('.tif')[0]+'.xml'
		if(file.split('_Tile_')[0]!=file):
			filexml=file.split('_Tile_')[0]+'.xml'

	#	print(file)
	#	print (filexml)

		strTif = file.split('.tif')[0]	+ '.tif'
		strTfw = file.split('.tif')[0]	+ '.tfw'
		strMNSOut ='MNS_Num' + strTif.split('Z_Num')[-1]
		strMNSTfwOut = 'MNS_Num' + strTfw.split('Z_Num')[-1]
		if(numero==numeromax):
			strMNSOut ='MNS_Final_Num' + strTif.split('Z_Num')[-1]
			strMNSTfwOut = 'MNS_Final_Num' + strTfw.split('Z_Num')[-1]

	#--------------- pb update lxml
	#tree = etree.parse(filexml)
	#for OrigineAlti in tree.xpath('/FileOriMnt/OrigineAlti'):
	#	orialti = OrigineAlti.text
	#for ResolutionAlti in tree.xpath('/FileOriMnt/ResolutionAlti'):
	#	resoalti = ResolutionAlti.text


	#récupération de la structure du fichier .xml
		tree = etree.parse(filexml)
		root = tree.getroot()

	#temp
		etree.tostring(tree.getroot())

		strBaliseOrialti = '/FileOriMnt/OrigineAlti'
		strBaliseResoalti = '/FileOriMnt/ResolutionAlti'


		for OrigineAlti in tree.xpath(strBaliseOrialti):
			orialti = OrigineAlti.text

		for ResolutionAlti in tree.xpath(strBaliseResoalti):
			resoalti = ResolutionAlti.text

		print(strTif, strMNSOut, orialti, resoalti)
		strGdalCalc = 'gdal_calc.py -A '+strTif+' --outfile='+strMNSOut+' --calc="'+ resoalti+'*A+'+orialti+'"'
		print(strGdalCalc)
		os.system(strGdalCalc)

		#fichier de georef
		shutil.copy( strTfw, strMNSTfwOut)
		print(strGdalCalc)


