import os
import json
import sqlite3
import sys

if len(sys.argv) != 3:
    print(f"Usage : python {sys.argv[0]} dossier_geojson base.db")
    quit()

json_folder = sys.argv[1]
database = sys.argv[2]

conn = sqlite3.connect(database)
conn.enable_load_extension(True)
conn.load_extension("mod_spatialite")
conn.enable_load_extension(False)

cursor = conn.cursor()

try:
    cursor.execute("SELECT InitSpatialMetaData(1)")
except sqlite3.OperationalError:
    pass

cursor.execute("""
    CREATE TABLE IF NOT EXISTS photos (
        url TEXT PRIMARY KEY,
        date_prise TEXT,
        lat REAL,
        lon REAL,
        mission TEXT,
        geometry TEXT,
        properties TEXT
    )
""")

try:
    cursor.execute("""
        SELECT AddGeometryColumn('photos', 'geom', 4326, 'GEOMETRY', 'XY')
    """)
except sqlite3.OperationalError:
    pass

try:
    cursor.execute("""
        SELECT CreateSpatialIndex('photos', 'geom')
    """)
except sqlite3.OperationalError:
    pass

conn.commit()

nb_ajoutes = 0

for json_file in sorted(os.listdir(json_folder)):
    if not json_file.endswith(".geojson"):
        continue

    json_path = os.path.join(json_folder, json_file)
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    for feature in data.get("features") or []:
        properties = feature["properties"]

        url = properties.get("url")
        if url is None:
            idta = properties["idta"].replace(" ", "")
            idta = idta.rsplit("_", 2)[0]
            numcli = str(properties["numcli"]).zfill(4)
            url = (
                f"IGNF_PVA_1-0__{properties['date']}__"
                f"C{properties['mission']}_{idta}_{numcli}.jp2"
            )
        url = url.split(".")[0]

        date_prise = properties.get("date")
        lat = properties.get("lat")
        lon = properties.get("lon")
        mission = properties.get("mission")

        geometry = feature.get("geometry")
        geometry_json = json.dumps(geometry) if geometry is not None else None
        properties_json = json.dumps(properties)

        if geometry is None:
            cursor.execute("""
                INSERT OR IGNORE INTO photos (
                    url, date_prise, lat, lon, mission, geometry, properties
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (url, date_prise, lat, lon, mission, geometry_json, properties_json))
        else:
            cursor.execute("""
                INSERT OR IGNORE INTO photos (
                    url, date_prise, lat, lon, mission, geometry, properties, geom
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, SetSRID(GeomFromGeoJSON(?), 4326))
            """, (url, date_prise, lat, lon, mission, geometry_json, properties_json, geometry_json))

        if cursor.rowcount == 1:
            nb_ajoutes += 1

    conn.commit()

total = cursor.execute("SELECT COUNT(*) FROM photos").fetchone()[0]
print(f"Lignes ajoutées : {nb_ajoutes}")
print(f"Total dans la base : {total}")

conn.close()