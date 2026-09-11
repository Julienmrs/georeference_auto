#from osgeo import gdal
import sys
import numpy as np

if(len(sys.argv)!=4):
    print(str(sys.argv[0])+str(" adresse_coord_terrain_L93.txt adresse_coord_im.txt adresse_export_tfw"))
    quit()


adresse_coordterrain=sys.argv[1]
adresse_coordim=sys.argv[2]
adresse_export_tfw=sys.argv[3]

coordterrain=np.genfromtxt(adresse_coordterrain)
coordim=np.genfromtxt(adresse_coordim)
nbpts=len(coordim)
A=np.zeros((2*nbpts,6))
B=np.zeros(2*nbpts)
B[0:nbpts]=coordterrain[:,0]
B[nbpts:]=coordterrain[:,1]
A[0:nbpts,0:2]=coordim
A[nbpts:,2:4]=coordim
A[0:nbpts,4]=1
A[nbpts:,5]=1
paramgeotransform=np.dot(np.linalg.inv(np.dot(A.T,A)),np.dot(A.T,B))

ftfw=open(adresse_export_tfw,"w")
for i in paramgeotransform:
    print(i)
    ftfw.write(str(i)+str("\n"))
ftfw.close()
