import json
import os
import sys


if(len(sys.argv)!=3):
    print(str(sys.argv[0])+str(" adresse.geojson adresse_export_coord.txt"))
    quit()

# Chemin vers le fichier geojson et vers l'export_txt
adresse_geojson=sys.argv[1]
adresse_coord_txt=sys.argv[2]

with open(adresse_geojson, "r") as f:
    json_data = json.load(f)

json_data.get("features")
features=json_data.get("features")
if(len(features)!=1):
    print(str("Pb il y a ")+str(len(features))+str(" objets\n"))

emprise=features[0]["geometry"]["coordinates"]
if(len(emprise)!=1):
    print(str("Pb il y a ")+str(len(emprise))+str(" objets emprises\n"))

fexportcoord=open(adresse_coord_txt,"w")
#for i in emprise[0]:
#    print(str(i[0])+str(" ")+str(i[1]))
#    fexportcoord.write(str(i[0])+str(" ")+str(i[1])+str("\n"))

nbpts=len(emprise[0])
if(nbpts!=9):
    print("Nb pts different de 9...")

#Le premier et le dernier point sont identiques, donc inutiles de les exporter tous les 2...
nbpts=nbpts-1
for i in range(len(emprise[0])-1):
    fexportcoord.write(str(emprise[0][i][0])+str(" ")+str(emprise[0][i][1])+str("\n"))
fexportcoord.close()
