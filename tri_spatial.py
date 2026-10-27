import sqlite3
import sys
import math


def distance(lat1, lon1, lat2, lon2):
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return 2 * 6371000 * math.asin(math.sqrt(a))


def find(lst_lien, i):
    while lst_lien[i] != i:
        lst_lien[i] = lst_lien[lst_lien[i]]
        i = lst_lien[i]
    return i


def union(lst_lien, i, j):
    ri, rj = find(lst_lien, i), find(lst_lien, j)
    if ri != rj:
        lst_lien[ri] = rj


def regrouper(lst_cliches, seuil):
    lst_lien = list(range(len(lst_cliches)))

    for i in range(len(lst_cliches)):
        for j in range(i + 1, len(lst_cliches)):
            _, lat1, lon1 = lst_cliches[i]
            _, lat2, lon2 = lst_cliches[j]
            if distance(lat1, lon1, lat2, lon2) <= seuil:
                union(lst_lien, i, j)

    groupes = {}
    for i, (url, lat, lon) in enumerate(lst_cliches):
        groupes.setdefault(find(lst_lien, i), []).append(url)

    return list(groupes.values())


def assigner_dossiers(lst_cliches, seuil):
    dossiers = {}
    for groupe in regrouper(lst_cliches, seuil):
        for url in groupe:
            dossiers[url] = groupe[0]
    return dossiers


def charger_depuis_base(database, urls):
    conn = sqlite3.connect(database)
    cursor = conn.cursor()
    placeholders = ",".join("?" for _ in urls)
    rows = cursor.execute(
        f"SELECT url, lat, lon FROM photos WHERE url IN ({placeholders})", urls
    ).fetchall()
    conn.close()
    return rows


def lire_liste(fichier):
    with open(fichier, "r", encoding="utf-8") as f:
        return [ligne.strip() for ligne in f if ligne.strip()]


if __name__ == "__main__":
    if len(sys.argv) not in (4, 5):
        print(f"Usage : python {sys.argv[0]} base.db seuil_metres list_dl.txt [--dossiers]")
        quit()

    database = sys.argv[1]
    seuil = float(sys.argv[2])
    urls = lire_liste(sys.argv[3])

    lst_cliches = charger_depuis_base(database, urls)

    if len(sys.argv) == 5 and sys.argv[4] == "--dossiers":
        for url, dossier in assigner_dossiers(lst_cliches, seuil).items():
            print(url, dossier)
    else:
        for groupe in regrouper(lst_cliches, seuil):
            print(" ".join(groupe))