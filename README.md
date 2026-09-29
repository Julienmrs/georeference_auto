# Environnement du pipeline

## Environnement Conda 

Depuis la racine du dépôt, on crée l'environnement une seule fois :

```bash
conda env create -f environment.yml
```

Faut l'activer et après on peut normalement lancer la pipeline / les différents programme  :

```bash
conda activate ign-pva
```

Pour lancer la pipeline
```bash
bash pipeline.sh
```

## Versions incluses

| Outil / bibliothèque | Version |
| --- | --- |
| Python | `3.11.5` |
| PyTorch CPU | `2.1.0` |
| NumPy | `1.26.0` |
| OpenCV Python | `4.8.1.78` |
| Matplotlib | `3.8.0` |
| GDAL / OGR | `3.8.4` |
| GeoTIFF / `listgeo` | `1.7.3` |
| Wget | `1.21.4` |
| Make | `4.4.1` |
| psycopg2-binary | `2.9.9` |

Les versions proviennent de l'environnement SuperGlue existant et des outils GIS employés par les scripts. La configuration est dans `environment.yml`.

## Nécessite les archives les fichiers de missions de l'ign

On se sert des fichiers des missions contenant les métadonnées sur les pva l'archives s'appelle initialement `photos-aeriennes-ign-master.zip` le dossier extrait est à placer à la racine du dossier.

## Comment lancer la pipeline

Remplir le fichier_a_traiter par défaut le fichier  `list_dl.txt` avec les noms de clichés à géoréférencer. 
Lancer le script `pipeline.sh` par exemple avec :
```bash
bash pipeline.sh
``` 

## Bilan

La pipeline fonctionne en général, il se peut que des téléchargements ne fonctionnent pas, mais dans ce cas les tests détectent le problème et empêchent que ça impacte la suite.

Il reste des petites choses à effectuer ainsi que des pistes que j'aurai aimé explorer avec plus de temps ou un peu d'encadrements:

- Modifier le script pour le traitement à 5m et le script export.

- Optimiser certains appels, piste de se servir plus de la BDD, jsp si ça ira forcément plus vite, mais à tenter.

- Changer le script d’export dans la piste de traiter les fichiers un à un. Dans l'optique de m'être en place la parallélisation, mieux vaut qu’il traite uniquement un fichier et pas l’ensemble des dossiers.

- Changer les noms des scripts et faire un nettoyage de tous les fichiers inutiles, ça ne devrait pas être très dur, j'ai fait en sorte que dans chaque appel, les autres fichiers soient clairs. Je ne savais juste pas de quoi j'avais le droit de changer pendant mon stage. 

- La piste de la relation entre des clichés à différentes époques pour des zones d'ont l'OCS à grandement évoluée. 
Il y a aussi l'éventualité de se contenter du géoréférencement grossier.

- J'utilise actuellement une BDD SQLite3 afin de ne pas m'embêter avec la gestion des géométries et d'avoir à me connecter à PostGIS. Il suffit de lancer une recherche d'informations directement dans la BDD.

- Possibilité de se servir davantage de la BDD. Actuellement, elle sert uniquement à vérifier la présence des données. On pourrait également récupérer directement les métadonnées depuis celle-ci. Cependant, l'enchaînement entre la BDD et la lecture du JSON associé est suffisamment rapide pour le moment.

##
