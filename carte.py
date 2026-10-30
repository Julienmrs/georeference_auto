import sqlite3
import sys

from flask import Flask, request, Response, render_template

if len(sys.argv) != 2:
    print(f"Usage : python {sys.argv[0]} base.db")
    quit()

db = sys.argv[1]
LIMITE_AFFICHAGE = 2000

app = Flask(__name__)


def connexion():
    conn = sqlite3.connect(db)
    conn.enable_load_extension(True)
    conn.load_extension("mod_spatialite")
    conn.enable_load_extension(False)
    return conn


@app.route("/")
def accueil():
    return render_template("index.html")


@app.route("/recherche")
def recherche():
    xmin = float(request.args["xmin"])
    xmax = float(request.args["xmax"])
    ymin = float(request.args["ymin"])
    ymax = float(request.args["ymax"])
    annee_min = request.args.get("annee_min", "1970")
    annee_max = request.args.get("annee_max", "2020")

    conn = connexion()
    cursor = conn.cursor()

    total = cursor.execute("""
        SELECT COUNT(*) FROM photos
        WHERE ROWID IN (
            SELECT pkid FROM idx_photos_geom
            WHERE xmin <= ? AND xmax >= ? AND ymin <= ? AND ymax >= ?
        )
        AND date_prise BETWEEN ? AND ?
    """, (xmax, xmin, ymax, ymin, f"{annee_min}-01-01", f"{annee_max}-12-31")).fetchone()[0]

    rows = cursor.execute("""
        SELECT url, lat, lon FROM photos
        WHERE ROWID IN (
            SELECT pkid FROM idx_photos_geom
            WHERE xmin <= ? AND xmax >= ? AND ymin <= ? AND ymax >= ?
        )
        AND date_prise BETWEEN ? AND ?
        LIMIT ?
    """, (xmax, xmin, ymax, ymin, f"{annee_min}-01-01", f"{annee_max}-12-31", LIMITE_AFFICHAGE)).fetchall()

    conn.close()

    points = [{"url": r[0], "lat": r[1], "lon": r[2]} for r in rows]
    return {"total": total, "points": points}


@app.route("/export")
def export():
    xmin = float(request.args["xmin"])
    xmax = float(request.args["xmax"])
    ymin = float(request.args["ymin"])
    ymax = float(request.args["ymax"])
    annee_min = request.args.get("annee_min", "1900")
    annee_max = request.args.get("annee_max", "2030")
    conn = connexion()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT url FROM photos
        WHERE ROWID IN (
            SELECT pkid FROM idx_photos_geom
            WHERE xmin <= ? AND xmax >= ? AND ymin <= ? AND ymax >= ?
        )
        AND date_prise BETWEEN ? AND ?
    """, (xmax, xmin, ymax, ymin, f"{annee_min}-01-01", f"{annee_max}-12-31"))

    def generer():
        for (url,) in cursor:
            yield url + "\n"
        conn.close()

    return Response(generer(), mimetype="text/plain",
                     headers={"Content-Disposition": "attachment; filename=selection.txt"})


if __name__ == "__main__":
    app.run(debug=True)