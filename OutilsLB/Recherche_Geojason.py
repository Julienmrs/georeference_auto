import json
import os

# Chemin complet vers le dossier contenant les fichiers GeoJSON
#json_folder = r"C://Users//hp//Desktop//Donnees_Projet//photos-aeriennes-ign-master//photos-aeriennes-ign-master//data//pva"
json_folder = "$ROOT_DIR/Piles_photos_CLB/photos-aeriennes-ign-master/photos-aeriennes-ign-master/data/pva/"

# Chemin complet vers le fichier image
# image_file = r"C://Users//hp//Desktop//Donnees_Projet//Piles_photos_CLB//IR_bocage_1_image//IGNF_PVA_1-0__1986-07-16__C1641-0013_1986_IFN32_0604.jp2"

# image_file = r"C://Users//hp//Desktop//Donnees_Projet//Piles_photos_CLB//NB_forets_champs_urbain_pile_de_2//IGNF_PVA_1-0__2000-06-18__CA00S00911_2000_FD15-43_1055.jp2"
# image_file = r"C://Users//hp//Desktop//Donnees_Projet//Piles_photos_CLB//RVB_forets_champs_pentes_pile_de_2//IGNF_PVA_1-0__1991-08-19__C91SAA2102_1991_FD21_1035.jp2"
# image_file = r"C://Users//hp//Desktop//Donnees_Projet//Piles_photos_CLB//IGNF_PVA_1-0__1991-08-19__C91SAA2102_1991_FD21_1038.jp2"

# image_file = r"F:\\Georeferencing_Aerial_Image\\0_Input\\IGNF_PVA_1-0__1998-05-22__CA98S00912_1998_FD13-83_0111.jp2"



import sys


if(len(sys.argv)!=3):
    print(str(sys.argv[0])+str(" adresse_repertoire_pva_geojson adresse_cliche.jp2"))
    quit()

# Chemin vers le fichier geojson et vers l'export_txt
json_folder=sys.argv[1]
image_file=sys.argv[2]


# Extraire le nom de fichier
image_name = os.path.basename(image_file)

# Déterminer le nom de fichier pour le nouveau fichier GeoJSON
output_geojson = os.path.splitext(image_file)[0] + ".geojson"

# Extraire la date de l'image
image_date = image_name.split("__")[1]

# Liste pour stocker les entités correspondantes
entities = []
trouver = False

# Parcourir les fichiers GeoJSON dans le dossier
for json_file in os.listdir(json_folder):
    # Vérifier que le fichier est un fichier GeoJSON
    if json_file.endswith(".geojson"):
        print(json_file)
        # Chemin complet vers le fichier GeoJSON
        json_path = os.path.join(json_folder, json_file)
        # Lire le contenu du fichier GeoJSON
        with open(json_path, "r") as f:
            json_data = json.load(f)
        # Vérifier que le fichier contient des features
        if json_data.get("features"):
            # Parcourir les features et extraire les entités correspondantes
            for feature in json_data["features"]:
                # if feature.get("properties") and feature["properties"].get("url") == image_name:
                if feature["properties"]["url"] == image_name:
                    trouver = True
                    # Extraire les propriétés de chaque entité
                    properties = feature["properties"]
                    # Extraire la géométrie de chaque entité
                    geometry = feature["geometry"]
                    # Ajouter chaque entité dans la liste des entités
                    entities.append({
                        "type": "Feature",
                        "geometry": geometry,
                        "properties": properties
                    })
                    print(f"Le fichier GeoJSON pour l'image {image_name} est {json_file}.")
                    # Écrire les entités dans un nouveau fichier GeoJSON
                    with open(output_geojson, "w") as f:
                        # Créer un dictionnaire GeoJSON avec les entités séparées
                        geojson = {
                            "type": "FeatureCollection",
                            "features": entities
                        }
                        # Écrire le dictionnaire GeoJSON dans le fichier de sortie
                        json.dump(geojson, f)   
                    break
        else:
            print(f"Aucune correspondance trouvée dans les fichiers {json_file}.")
    if trouver:
        break
print('••••••Finish•••••')
