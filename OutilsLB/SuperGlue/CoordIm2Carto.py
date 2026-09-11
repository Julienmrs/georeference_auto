#from osgeo import gdal
import sys
import numpy as np

if(len(sys.argv)!=4):
    print(str(sys.argv[0])+str(" adresse_fichier_result.txt adresse_tfw.txt adresse_ptsterrain.txt adresse_ptsim.txt"))
    quit()


adresse_fichier_result=sys.argv[1]
adresse_tfw=sys.argv[2]
adresse_export_tfw=sys.argv[3]

result=np.genfromtxt(adresse_fichier_result)
tfw=np.genfromtxt(adresse_tfw)

a=tfw[0]
b=tfw[1]
c=tfw[2]
d=tfw[3]
E0=tfw[4]
N0=tfw[5]

nbpts=len(result)

coordterrain=np.zeros((nbpts,2))
coordim=result[:,2:4]

coordterrain[:,0]=a*result[:,0]+b*result[:,1]+E0
coordterrain[:,1]=c*result[:,0]+d*result[:,1]+N0

fpts=open("export_pts_terrain.txt","w")
for n in range(nbpts):
    fpts.write(str(coordterrain[n,0])+str(" ")+str(coordterrain[n,1])+str("\n"))
fpts.close()

fpts=open("export_pts_cliche.txt","w")
for n in range(nbpts):
    fpts.write(str(coordim[n,0])+str(" ")+str(coordim[n,1])+str("\n"))
fpts.close()





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
