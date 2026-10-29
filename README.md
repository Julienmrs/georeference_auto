# Environnement du pipeline

## Environnements Conda

Il y a deux environnements : un pour le traitement (lourd, GPU) et un pour les outils annexes (léger).

Depuis la racine du dépôt, on crée les deux :

```bash
conda env create -f env_outils.yml
conda env create -f environment.yml
```

Pour l'extraction des métadonnées et la carte web :
```bash
conda activate ign-pva-outils
```

Pour le traitement (pipeline, géoréférencement) :
```bash
conda activate ign-pva
```

### Versions incluses — `ign-pva` (traitement)

| Outil / bibliothèque | Version |
| --- | --- |
| Python | `3.11.5` |
| PyTorch (GPU, `pytorch-cuda`) | `2.1.0` |
| NumPy | `1.26.0` |
| OpenCV Python | `4.8.1.78` |
| Matplotlib | `3.8.0` |
| GDAL / OGR | `3.8.4` |
| GeoTIFF / `listgeo` | `1.7.3` |
| Wget | `1.21.4` |
| Make | `4.4.1` |
| psycopg2-binary | `2.9.9` |

### Versions incluses — `ign-pva-outils` (extraction + carte)

| Outil / bibliothèque | Version |
| --- | --- |
| Python | `3.11.5` |
| Flask | - |
| requests | - |

### Dépendance système : SpatiaLite

La base est une base SQLite + SpatiaLite `spatialite` est une bibliothèque système, il faut l'avoir installée au niveau de l'OS (`libsqlite3-mod-spatialite`).

## Récupération des métadonnées

`extract.py` interroge directement le flux WFS de la Géoplateforme et écrit les métadonnées des clichés PVA, réparties par année, au même format (GeoJSON, mêmes 16 champs) que l'ancienne extraction de 2016.

```bash
conda activate ign-pva-outils
python3 extract.py data/pva
```

Il est toujours possible de se servir des données de 2016, le mieux est de les télécharger dans un dossier séparé.
## Base de données

Création ou mise à jour de la base (SQLite + SpatiaLite) à partir d'un dossier de fichiers `.geojson` :

```bash
conda activate ign-pva-outils
python3 test_bdd_spatial.py data/pva base.db
```

Le script peut être relancé plusieurs fois, y compris sur un autre dossier de données (par exemple l'ancienne extraction), sans recréer la base ni dupliquer les lignes déjà présentes (`INSERT OR IGNORE` sur l'`url`).

### Parcourir la base sur une carte

`carte_bdd.py` lance une petite interface web locale (Flask) pour chercher des clichés par zone géographique et par année, et exporter la sélection dans un fichier `.txt` au format attendu par `list_dl.txt`.

```bash
conda activate ign-pva-outils
python3 carte_bdd.py index_pva_spatial.db
```
Puis ouvrir `http://127.0.0.1:5000`. Le fond de carte (OpenStreetMap) a besoin d'une connexion Internet, la base elle-même reste locale.

## Comment lancer la pipeline

Remplir `list_dl.txt` (un nom de cliché par ligne) ou utiliser `carte_bdd.py` pour en générer un à partir d'une sélection sur la carte.

```bash
conda activate ign-pva
bash pipeline.sh
```

Deux options sont réglables en haut de `pipeline.sh` :
- `regroupement_actif` + `seuil_regroupement` : si actif, les clichés suffisamment proches (sous le seuil, distance calculée sur leur géométrie réelle et pas juste leur centre) sont téléchargés dans un même dossier et traités ensemble (une seule BDOrtho), les autres restent séparés. Si inactif, chaque cliché garde son propre dossier comme avant.
- `nettoyage_actif` : si actif, les dossiers de travail bruts sont supprimés en fin de chaîne, ne laissant que les résultats finaux (`final/`, `final_spg/`, `initial/`).


### Traiter un groupe de clichés choisi à la main

`pipeline_chantier.sh` est une variante pour forcer un ensemble de clichés dans un même dossier, sans tenir compte de la distance (par exemple un chantier qu'on sait vouloir traiter ensemble). Elle enchaîne ensuite la même suite de traitement que `pipeline.sh`, jusqu'à l'export et le nettoyage mais produit quand même un avertissement dans le cas d'un grand chantier.

```bash
bash pipeline_chantier.sh liste.txt nom_du_chantier [seuil_avertissement]
```

## Description du code principal

`pipeline.sh` Pipeline complète : vérification de présence en base, téléchargement, vérification de cohérence, initialisation + recalage, export, nettoyage optionnel.

`pipeline_chantier.sh` Variante pour forcer un groupe de clichés donné dans un même dossier de traitement, peu importe la distance.

`extract.py` Récupère les métadonnées des clichés PVA depuis le WFS de la Géoplateforme, par année, au format legacy.

`creer_bdd_spatial.py` Crée/met à jour la base SQLite + SpatiaLite (table `photos`, colonne géométrique indexée `geom`) à partir d'un dossier de GeoJSON.

`tri_spatial.py` Regroupe des clichés par proximité géographique.

`test_presence_bdd.py` Vérifie la présence des clichés de `list_dl.txt` dans la base, écrit `pva_present.txt` / `pva_absent.txt`.

`download.sh` Télécharge les clichés présents.

`bash_processus.sh` Prépare les listes de clichés par chantier, initialise le géoréférencement approché (`bash_initialisation.sh`) et télécharge la BDOrtho de chaque chantier (2 tentatives, modifiable).

`bash_initialisation.sh` Recherche les métadonnées approchées via la base, détecte le bord du cliché (`Coherence.LINUX DetecteBord`, activable/désactivable en second paramètre) et calcule les coordonnées image pour les 4 rotations testées.

`bash_traitement_serie2_export_points_gdalpam_affonly.sh` Traite un cliché donné : recalage fin par 2 méthodes (HIATUS/Akaub et SuperGlue), choix de la meilleure rotation, export des points de correspondance pour les 2 méthodes.

`bash_export.sh` Étape de visualisation : rassemble et organise les résultats finaux (`final/`, `final_spg/`, `initial/`) pour s'y retrouver sans fouiller les fichiers temporaires. Prennent le dossier de traitement en paramètre.

`cleanup.sh` Supprime les dossiers de travail bruts (listés dans `liste_chantiers_ok.txt` et `liste_chantiers_kc.txt`) en fin de chaîne, ne garde que les dossiers finaux.

## Bilan

La pipeline fonctionne en général tant que les clichés sont dans la BDD ; il se peut que des téléchargements ne fonctionnent pas, mais dans ce cas les tests détectent le problème et empêchent que ça impacte la suite.
