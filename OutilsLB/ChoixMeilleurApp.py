import sys
import numpy as np

#if(len(sys.argv)!=3):
#    print(str(sys.argv[0])+str(" adresse_image adresse_export_coord_txt"))
#    quit()

nbptsmax=-1;
adresse_result_max=""
nbest=0
for n in range(1,len(sys.argv)):
    adresse_result=str(sys.argv[n])
    #print(adresse_result)
    nbpts=np.shape(np.genfromtxt(adresse_result))[0]
    if(nbpts>nbptsmax):
        nbptsmax=nbpts
        adresse_result_max=adresse_result
        nbest=n

print(nbest-1)
#f=open(adresse_coord_txt+str("_rot0"),"w")
#f.write("0 0\n")
#f.close()

