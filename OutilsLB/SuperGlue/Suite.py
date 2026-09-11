ptsarec = np.array(ptsarec, dtype=np.uint16)
ptsref = np.array(ptsref, dtype=np.uint16)
# Calculer la matrice de transformation à partir des points homologues
H, _ = cv2.findHomography(ptsref, ptsarec, cv2.RANSAC, 5.0)
print('H',H)


img = cv2.imread("old.tif")
rows, cols = img.shape[:2]
rectified = np.zeros((rows, cols, 3), dtype=np.uint16)
rectified = cv2.warpPerspective(img, H, rectified.shape[:2], rectified)
cv2.imwrite("old.rec.jpg", rectified);




#Exemple chaine complete
!python GeoJson2ExportCoordTerrain.py IGNF_PVA_1-0__2004-06-26__CP04000702_2004_fd74_c_20000_0017.geojson  toto.coord.txt
!python ExportCoordIm.py IGNF_PVA_1-0__2004-06-26__CP04000702_2004_fd74_c_20000_0017.jp2 toto.coordim.txt
!python CalculTransfo.py toto.coord.txt toto.coordim.txt toto.tfw
!apt install gdal-bin
!gdal_translate IGNF_PVA_1-0__2004-06-26__CP04000702_2004_fd74_c_20000_0017.jp2 toto.tif


import skimage
import skimage.io
import numpy as np

!cp old.tif toto.tif

im_rot0=skimage.io.imread("toto.tif")
im_rot90=np.rot90(im_rot0)
skimage.io.imsave("toto_rot90.tif",im_rot90)
im_rot180=np.rot90(im_rot0,2)
skimage.io.imsave("toto_rot180.tif",im_rot180)
im_rot270=np.rot90(im_rot0,3)
skimage.io.imsave("toto_rot270.tif",im_rot270)

