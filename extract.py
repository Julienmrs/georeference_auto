import json
import math
import re
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path

import requests

# Extrait les infos des PVA (WFS Geoplateforme) et les range par année en GeoJSON,
# avec les mêmes champs que l'ancienne extraction de 2016.
# python3 extract.py data/pva

WFS = "https://data.geopf.fr/wfs/ows"
LAYER = "pva:image"
PAGE_SIZE = 5000
SRS = "CRS:84"

session = requests.Session()
session.headers["User-Agent"] = "pva-extract"


def wfs_get(params, retries=4):
    """ Effectue une requête WFS avec gestion des erreurs et des tentatives de réessai.

    Args:
        params (dict): Paramètres de la requête WFS.
        retries (int, optional): Nombre de tentatives de réessai. par défaut 4.

    Returns:
        requests.Response: La réponse de la requête WFS.
    """
    query = {"SERVICE": "WFS", "VERSION": "2.0.0"}
    query.update(params)
    for tentative in range(1, retries + 1):
        try:
            r = session.get(WFS, params=query, timeout=120)
            r.raise_for_status()
            return r
        except requests.RequestException as exc:
            if tentative == retries:
                raise
            print(f"{exc} -> nouvel essai")
            time.sleep(2 ** tentative)


def compte_result():
    """compte le nombre d'extractions attendu pour savoir si certaines n'ont pas marché ainsi qu'avoir une idée du nombre total

    Returns:
        int: le nombre d'extractions attendues
    """
    r = wfs_get({"REQUEST": "GetFeature", "TYPENAMES": LAYER, "RESULTTYPE": "hits"})
    root = ET.fromstring(r.content)
    value = root.attrib.get("numberMatched", "")
    return int(value) if value.isdigit() else None


def fetch_page(start):
    """ Récupère une page de résultats WFS à partir de la page indiquée.

    Args:
        start (int): L'index de départ de la page à récupérer.

    Returns:
        dict: Les données de la page récupérée.
    """
    params = {
        "REQUEST": "GetFeature",
        "TYPENAMES": LAYER,
        "OUTPUTFORMAT": "application/json",
        "COUNT": PAGE_SIZE,
        "STARTINDEX": start,
        "SRSNAME": SRS,
    }
    return wfs_get(params).json()


def get_features():
    """ Génère les features WFS en paginant les résultats

    Yields:
        dict: Les features WFS récupérées.
    """
    total = compte_result()
    print(f"{total} objets annoncés")

    start = 0
    while True:
        features = fetch_page(start).get("features", [])
        if not features:
            break
        for feature in features:
            yield feature
        start += len(features)
        print(f"{start}/{total}")
        if total is not None and start >= total:
            break


def get_year(properties):
    """ Extrait l'année de la date du cliché à partir des propriétés d'une feature.


    Args:
        properties (dict): Les propriétés de la feature.

    Returns:
        str: L'année extraite de la date du cliché.
    """
    match = re.match(r"\s*((?:18|19|20)\d{2})", str(properties.get("date_cliche") or ""))
    return match.group(1) if match else "inconnu"


def polygon_surf_km2(geometry):
    if not geometry or geometry.get("type") != "Polygon":
        return None
    ring = geometry["coordinates"][0]
    phi = math.radians(sum(p[1] for p in ring) / len(ring))
    km_lat = 111.132954 - 0.559822 * math.cos(2 * phi) + 0.001175 * math.cos(4 * phi)
    km_lon = 111.41513 * math.cos(phi) - 0.09455 * math.cos(3 * phi) + 0.00012 * math.cos(5 * phi)
    pts = [(p[0] * km_lon, p[1] * km_lat) for p in ring]
    s = sum(pts[i][0] * pts[i + 1][1] - pts[i + 1][0] * pts[i][1] for i in range(len(pts) - 1))
    return abs(s) / 2


def polygon_centroid(geometry):
    """Récupère les coordonnées du centroid de la geometry afin de stocker l'information

    Args:
        geometry (dict): La géométrie pour laquelle récupérer le centroid.

    Returns:
        tuple: Les coordonnées du centroid (longitude, latitude).
    """
    if not geometry or geometry.get("type") != "Polygon":
        return None, None
    ring = geometry["coordinates"][0]
    a = cx = cy = 0.0
    for (x0, y0), (x1, y1) in zip(ring, ring[1:]):
        cross = x0 * y1 - x1 * y0
        a += cross
        cx += (x0 + x1) * cross
        cy += (y0 + y1) * cross
    if a == 0:
        return ring[0][0], ring[0][1]
    return cx / (3 * a), cy / (3 * a)


def conversion(feature):
    """ Convertit une feature WFS en un format GeoJSON avec les champs souhaités.

    Args:
        feature (dict): La feature WFS à convertir.

    Returns:
        dict: La feature au format GeoJSON attendue pour la bdd.
    """
    p = feature.get("properties", {})
    image_id = p.get("image_identifier")
    if not image_id:
        return None

    geometry = feature.get("geometry")
    lon, lat = polygon_centroid(geometry)
    date = (p.get("date_cliche") or "")[:10] or None
    numero = p.get("numero_image")
    orientation = p.get("orientation")

    properties = {
        "idcliche": image_id.split("__")[-1],
        "mission": p.get("dataset_identifier"),
        "numcli": None if numero is None else str(numero),
        "idta": None,
        "date": date,
        "res": None,
        "support": None,
        "type": None,
        "surface": polygon_surf_km2(geometry),
        "lon": lon,
        "lat": lat,
        "orientation": None if orientation is None else str(orientation),
        "url": image_id + ".jp2",
        "largeur": None,
        "hauteur": None,
        "taille": None,
    }
    return {"type": "Feature", "geometry": geometry, "properties": properties}


FOOTER = b"\n]}\n"


class ecriture_par_annee:
    """ Classe pour gérer l'écriture des features par année dans des fichiers GeoJSON distincts. """
    def __init__(self, output):
        self.output = Path(output)
        self.output.mkdir(parents=True, exist_ok=True)
        self.files = {}

    def add(self, year, feature):
        if year not in self.files:
            f = (self.output / f"{year}.geojson").open("wb", buffering=0)
            f.write(b'{"type":"FeatureCollection","features":[' + FOOTER)
            self.files[year] = [f, 0]

        f, count = self.files[year]
        data = json.dumps(feature, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        f.seek(-len(FOOTER), 2)
        f.write((b",\n" if count else b"\n") + data + FOOTER)
        self.files[year][1] += 1

    def close(self):
        for year, (f, count) in sorted(self.files.items()):
            f.close()
            print(f"{year}.geojson : {count} objets")


if len(sys.argv) != 2:
    print(f"Usage : python3 {sys.argv[0]} dossier_sortie")
    quit()

writer = ecriture_par_annee(sys.argv[1])
try:
    for feature in get_features():
        convertie = conversion(feature)
        if convertie is not None:
            writer.add(get_year(feature.get("properties", {})), convertie)
finally:
    writer.close()