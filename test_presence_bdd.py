import sqlite3
import sys
import os

if len(sys.argv) != 3:
    print(f"Usage : python {sys.argv[0]} base.db noms.txt")
    sys.exit(1)

database = sys.argv[1]
input_file = sys.argv[2]

present = set()
absent = set()

# Ouverture de la BDD en lecture seule
conn = sqlite3.connect(
    f"file:{os.path.abspath(database)}?mode=ro",
    uri=True
)

cursor = conn.cursor()

# On récupère tous les noms présents dans la BDD
cursor.execute("SELECT url FROM photos")

noms_bdd = {
    row[0]
    for row in cursor
    if row[0]
}

conn.close()

# Lecture de la liste à vérifier
with open(input_file, "r", encoding="utf-8") as fichier:
    for ligne in fichier:
        nom = ligne.strip()

        if not nom:
            continue

        # Enlève .jp2 ou .tif si présent
        nom = os.path.splitext(nom)[0]

        if nom in noms_bdd:
            present.add(nom)
        else:
            absent.add(nom)

present = sorted(present)
absent = sorted(absent)
# Ecriture 
with open("pva_present.txt", "w", encoding="utf-8") as fichier:
    fichier.write("\n".join(present) + "\n")

with open("pva_absent.txt", "w", encoding="utf-8") as fichier:
    fichier.write("\n".join(absent) + "\n")

print(f"Présents : {len(present)}")
print(f"Absents  : {len(absent)}")