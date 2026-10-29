from osgeo import gdal
import sys

if len(sys.argv) != 3:
    print(str(sys.argv[0]) + str(" adresse_image_ou_coord adresse_export_coord_txt"))
    quit()

adresse_entree = sys.argv[1]
adresse_coord_txt = sys.argv[2]

ds = gdal.Open(adresse_entree, gdal.GA_ReadOnly)

if ds is not None:
    nbcolonnes = ds.RasterXSize
    nblignes = ds.RasterYSize
    colonnemilieu = nbcolonnes / 2
    lignemilieu = nblignes / 2

    points = [
        (0, 0),
        (colonnemilieu, 0),
        (nbcolonnes, 0),
        (nbcolonnes, lignemilieu),
        (nbcolonnes, nblignes),
        (colonnemilieu, nblignes),
        (0, nblignes),
        (0, lignemilieu),
    ]
else:
    with open(adresse_entree) as f:
        points = [tuple(map(float, ligne.split())) for ligne in f if ligne.strip()]

p0, p1, p2, p3, p4, p5, p6, p7 = points

f=open(adresse_coord_txt+str("_rot0"),"w")
f.write(str(p0[0])+str(" ")+str(p0[1])+str("\n"))
f.write(str(p1[0])+str(" ")+str(p1[1])+str("\n"))
f.write(str(p2[0])+str(" ")+str(p2[1])+str("\n"))
f.write(str(p3[0])+str(" ")+str(p3[1])+str("\n"))
f.write(str(p4[0])+str(" ")+str(p4[1])+str("\n"))
f.write(str(p5[0])+str(" ")+str(p5[1])+str("\n"))
f.write(str(p6[0])+str(" ")+str(p6[1])+str("\n"))
f.write(str(p7[0])+str(" ")+str(p7[1])+str("\n"))
f.close()

f=open(adresse_coord_txt+str("_rot1"),"w")
f.write(str(p2[0])+str(" ")+str(p2[1])+str("\n"))
f.write(str(p3[0])+str(" ")+str(p3[1])+str("\n"))
f.write(str(p4[0])+str(" ")+str(p4[1])+str("\n"))
f.write(str(p5[0])+str(" ")+str(p5[1])+str("\n"))
f.write(str(p6[0])+str(" ")+str(p6[1])+str("\n"))
f.write(str(p7[0])+str(" ")+str(p7[1])+str("\n"))
f.write(str(p0[0])+str(" ")+str(p0[1])+str("\n"))
f.write(str(p1[0])+str(" ")+str(p1[1])+str("\n"))
f.close()

f=open(adresse_coord_txt+str("_rot2"),"w")
f.write(str(p4[0])+str(" ")+str(p4[1])+str("\n"))
f.write(str(p5[0])+str(" ")+str(p5[1])+str("\n"))
f.write(str(p6[0])+str(" ")+str(p6[1])+str("\n"))
f.write(str(p7[0])+str(" ")+str(p7[1])+str("\n"))
f.write(str(p0[0])+str(" ")+str(p0[1])+str("\n"))
f.write(str(p1[0])+str(" ")+str(p1[1])+str("\n"))
f.write(str(p2[0])+str(" ")+str(p2[1])+str("\n"))
f.write(str(p3[0])+str(" ")+str(p3[1])+str("\n"))
f.close()

f=open(adresse_coord_txt+str("_rot3"),"w")
f.write(str(p6[0])+str(" ")+str(p6[1])+str("\n"))
f.write(str(p7[0])+str(" ")+str(p7[1])+str("\n"))
f.write(str(p0[0])+str(" ")+str(p0[1])+str("\n"))
f.write(str(p1[0])+str(" ")+str(p1[1])+str("\n"))
f.write(str(p2[0])+str(" ")+str(p2[1])+str("\n"))
f.write(str(p3[0])+str(" ")+str(p3[1])+str("\n"))
f.write(str(p4[0])+str(" ")+str(p4[1])+str("\n"))
f.write(str(p5[0])+str(" ")+str(p5[1])+str("\n"))
f.close()