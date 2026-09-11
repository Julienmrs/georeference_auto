import cv2
import numpy as np
import sys
import os

adresse_outils_superglue=str(sys.argv[1])
adresse_image_ref=str(sys.argv[2])
adresse_image_arec=str(sys.argv[3])
adresse_result=str(sys.argv[4])
#Version Avec Creation d'un repertoire temporaire

#os.system(str("mkdir results im2match; cp "+adresse_image_ref+" im2match/new.tif; cp "+adresse_image_arec+" im2match/old.tif;"))
os.system(str("rm -r results_"+adresse_result))
os.system(str("mkdir results_"+adresse_result))

adresse_paires=adresse_result+str(".pairs.txt")

with open(adresse_paires, 'w') as fpairs:
    fpairs.write(adresse_image_ref+str(" ")+adresse_image_arec)
fpairs.close()

im=cv2.imread(adresse_image_ref)
NbLignes = im.shape[0]
NbColonnes = im.shape[1]
print(str(NbColonnes)+" "+str(NbLignes))


#Au choix on force la taille de l'image reechantillonnee a 1000x1000 ou uniquement le cote le plus long a 1000
Resize=True
Resize_CarreVsRectangle=True
if(Resize):
  if(Resize_CarreVsRectangle):
    matchingNbLignes = 1000
    matchingNbColonnes = 1000
  else:
    matchingratio = 1000.0/max(NbColonnes,NbLignes)
    matchingNbLignes = int(NbLignes*matchingratio)
    matchingNbColonnes = int(NbColonnes*matchingratio)
else:
  matchingNbLignes = NbLignes
  matchingNbColonnes = NbColonnes


matchingratio_x=NbColonnes/matchingNbColonnes
matchingratio_y=NbLignes/matchingNbLignes
print(matchingNbColonnes, matchingNbLignes)

str("pairs_")
#os.system(str("python "+adresse_outils_superglue+"/match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results  --resize ")+str(matchingNbColonnes)+str(" ")+str(matchingNbLignes)+str(" --superglue outdoor"))
os.system(str("python "+adresse_outils_superglue+"/match_pairs.py --input_pairs "+adresse_paires+" --input_dir ./ --output_dir results_"+adresse_result+"  --resize ")+str(matchingNbColonnes)+str(" ")+str(matchingNbLignes)+str(" --superglue outdoor"))
#Semble mieux fonctionner avec le modele outdoor
#os.system(str("python match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results  --resize ")+str(matchingNbColonnes)+str(" ")+str(matchingNbLignes)+str(" --superglue indoor"))

#Version ligne de commande
#!python match_pairs.py -h
#!python match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results  --resize 1000 1000 --superglue outdoor
#!python match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results --resize 1000 1000  --superglue indoor



#Export du resultat dans un fichier .result classique
os.system(str("mv results_"+adresse_result+"/*.npz results_"+adresse_result+"/new_old_matches.npz"))
#resultnpz=np.load("results/new_old_matches.npz")
resultnpz=np.load(str("results_"+adresse_result+"/new_old_matches.npz"))
pts1 = []
pts2 = []
result = []
resulttxt=''
for i in range(len(resultnpz['matches'])):
    if resultnpz['matches'][i] == -1:
        continue
    x0 = resultnpz['keypoints0'][i][0] * matchingratio_x
    y0 = resultnpz['keypoints0'][i][1] * matchingratio_y
    x1 = resultnpz['keypoints1'][resultnpz['matches'][i]][0] * matchingratio_x
    y1 = resultnpz['keypoints1'][resultnpz['matches'][i]][1] * matchingratio_y
    pts1.append([x0, y0])
    pts2.append([x1, y1])
    result.append([x0, y0, x1 , y1])
    resulttxt+=str(x0)+" "+str(y0)+" "+str(x1)+" "+str(y1)+"\n"

#print(pts1)
#print(pts2)
#print(result)
print(len(result))

#with open("new.-.old.result", 'w') as f:
with open(adresse_result, 'w') as f:
    f.write(resulttxt)
f.close()

os.system(str("rm -r results_"+adresse_result))
os.system(str("rm "+adresse_paires))
