from osgeo import gdal
import sys

if(len(sys.argv)!=3):
    print(str(sys.argv[0])+str(" adresse_image adresse_export_coord.txt"))
    quit()
    
adresse_image=sys.argv[1]
adresse_coord_txt=sys.argv[2]

ds = gdal.Open(adresse_image, gdal.GA_ReadOnly)
nbcolonnes = ds.RasterXSize
nblignes = ds.RasterYSize


colonnemilieu=nbcolonnes/2
lignemilieu=nblignes/2

f=open(adresse_coord_txt,"w")
f.write("0 0\n")
f.write(str(colonnemilieu)+str(" 0\n"))
f.write(str(nbcolonnes)+str(" 0\n"))
f.write(str(nbcolonnes)+str(" ")+str(lignemilieu)+str("\n"))
f.write(str(nbcolonnes)+str(" ")+str(nblignes)+str("\n"))
f.write(str(colonnemilieu)+str(" ")+str(nblignes)+str("\n"))
f.write(str(0)+str(" ")+str(nblignes)+str("\n"))
f.write(str(0)+str(" ")+str(lignemilieu)+str("\n"))
f.close()

