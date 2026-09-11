import cv2
import numpy as np
import sys
import os

#adresse_outils_superglue=str(sys.argv[1])
adresse_outils_superglue=os.path.dirname(str(sys.argv[0]))
adresse_image_ref=str(sys.argv[1])
adresse_image_arec=str(sys.argv[2])
adresse_result=str(sys.argv[3])


repertoire_result=os.path.dirname(adresse_result)
if(repertoire_result==""):
    repertoire_result="./"
adresse_paires=(os.path.splitext(adresse_result))[0]+str(".pairs.txt")

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
os.system(str("python "+adresse_outils_superglue+"/match_pairs.py --input_pairs "+adresse_paires+" --input_dir ./ --output_dir "+repertoire_result+"/  --resize ")+str(matchingNbColonnes)+str(" ")+str(matchingNbLignes)+str(" --superglue outdoor"))
#Semble mieux fonctionner avec le modele outdoor
#os.system(str("python match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results  --resize ")+str(matchingNbColonnes)+str(" ")+str(matchingNbLignes)+str(" --superglue indoor"))

#Version ligne de commande
#!python match_pairs.py -h
#!python match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results  --resize 1000 1000 --superglue outdoor
#!python match_pairs.py --input_pairs pairs.txt --input_dir im2match --output_dir results --resize 1000 1000  --superglue indoor



#Export du resultat dans un fichier .result classique
adresse_result_tmpnpz=str(repertoire_result+"/"+os.path.splitext(os.path.basename(adresse_image_ref))[0]+"_"+os.path.splitext(os.path.basename(adresse_image_arec))[0]+"_matches.npz")

#resultnpz=np.load("results/new_old_matches.npz")
resultnpz=np.load(adresse_result_tmpnpz)
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

os.system(str("rm "+adresse_result_tmpnpz+" "+adresse_paires))
