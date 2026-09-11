import json
import sqlite3
import os
import sys


if len(sys.argv) != 4:
    #Si on a lance ce fichier argv[0] = nom du fichier, argv[1] = base.db, argv[2] = image.tif, argv[3] = sortie.geojson
    print(f"Usage : python {sys.argv[0]} base.db image.tif sortie.geojson")
    quit()

database = sys.argv[1]
image_file = sys.argv[2]
output_geojson = sys.argv[3]

# Nom du fichier image
image_name = os.path.basename(image_file)
image_name = image_name.replace(".jp2", "").replace(".tif", "")
# print(image_name) #debug
# Connexion à la base
conn = sqlite3.connect(database)
cursor = conn.cursor()

cursor.execute("""
SELECT geometry, properties
FROM photos
WHERE url = ? 
""", (image_name,))

result = cursor.fetchone()

conn.close()

if result is None:
    print(f"Aucune correspondance trouvée pour {image_name}")
    with open("fichier_absent_bdd.txt", "a", encoding="utf-8") as fichier:
        fichier.write(f"{image_name}\n")
    quit()

geometry = json.loads(result[0])
properties = json.loads(result[1])

geojson = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": geometry,
            "properties": properties
        }
    ]
}

with open(output_geojson, "w", encoding="utf-8") as f:
    json.dump(geojson, f)

# print(f"GeoJSON créé : {output_geojson}")