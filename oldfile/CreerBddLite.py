import os
import json
import sqlite3
import sys
import time
#python3 ./OutilsLB/CreerBddLite.py ./photos-aeriennes-ign-master/data/pva index_pva.db
# Juste pour savoir le temps qu'on prend
time_ini = time.time()
if len(sys.argv) != 3:
    print(f"Usage : python {sys.argv[0]} dossier_geojson base.db")
    quit()
# Fin du temps

#Recupere les arguments de la ligne de commande
json_folder = sys.argv[1]
database = sys.argv[2]

#Creation de la base SQLite
conn = sqlite3.connect(database)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS photos (
    url TEXT PRIMARY KEY,
    geometry TEXT,
    properties TEXT
)
""")

#On parcourt tous les fichiers geojson du dossier
for json_file in os.listdir(json_folder):

    if not json_file.endswith(".geojson"):
        continue

    print(f"Lecture de {json_file}")
    json_path = os.path.join(json_folder, json_file)
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if "features" not in data:
        continue
    if "features" not in data or not isinstance(data["features"], list):
        continue
    for feature in data["features"]:
        properties = feature["properties"]
        geometry = feature["geometry"]
        url = properties["url"]
        if url is None:
            idta = properties["idta"].replace(" ", "")
            idta = idta.rsplit("_", 2)[0]  # enlève _P_13000, _C_20000, ...
            numcli = str(properties["numcli"]).zfill(4)
            url = (
                f"IGNF_PVA_1-0__"
                f"{properties['date']}__"
                f"C{properties['mission']}_"
                f"{idta}_"
                f"{numcli}.jp2"
            )
            # On met aussi à jour le JSON enregistré dans la base
            # properties["url"] = url
        url = url.split(".")[0]
        # url_tif = url.replace(".jp2", ".tif")
        cursor.execute("""
            INSERT OR REPLACE INTO photos(url, geometry, properties)
            VALUES (?, ?, ?)
        """, (
            url,
            json.dumps(geometry),
            json.dumps(properties)
        ))

conn.commit()
conn.close()

print("Base SQLite creee")

# Pour mesurer le temps 
print(f"Temps d'exécution : {time.time() - time_ini:.2f} secondes")