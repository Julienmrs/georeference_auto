import numpy as np
import sys

if(len(sys.argv)!=4):
    print(str(sys.argv[0])+str(" adresse_coordim adresse_coordterr adresse_export_pam"))
    quit()
    
adresse_coordim=sys.argv[1]
adresse_coordterr=sys.argv[2]
adresse_exportpamxml=sys.argv[3]

coordim=np.genfromtxt(adresse_coordim)
coordterr=np.genfromtxt(adresse_coordterr)

fexportpamxml=open(adresse_exportpamxml,"w")

fexportpamxml.write("<PAMDataset>\n")
fexportpamxml.write(" <GCPList Projection='EPSG:2154'>\n")
nbpts=np.shape(coordim)[0]
for i in range(nbpts):
    fexportpamxml.write(str("  <GCP Id=\"")+str(i+1)+str("\" Pixel=\"")+str(coordim[i,0])+str("\" Line=\"")+str(coordim[i,1])+str("\" X=\"")+str(coordterr[i,0])+str("\" Y=\"")+str(coordterr[i,1])+str("\" />\n"))
 
fexportpamxml.write(" </GCPList>\n")
fexportpamxml.write("</PAMDataset>\n")
fexportpamxml.close()





