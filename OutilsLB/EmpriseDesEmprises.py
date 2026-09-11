import numpy as np
import sys

if(len(sys.argv)<3):
    print(str(sys.argv[0])+str(" adresse_liste_cliches adresse_export_emprise_des_emprises.txt [marge=0]"))
    quit()

adresse_liste_cliches=sys.argv[1]
adresse_export_emprise=sys.argv[2]
marge=0
if(len(sys.argv)==4):
    marge=float(sys.argv[3])

f=open(adresse_liste_cliches,"r")
liste_cliches=f.read().split()
f.close()

emp=[]
for nomcliche in liste_cliches:
    print(nomcliche)
    adresse_emprise=nomcliche+".L93.coordL93.txt"
    emptmp=np.genfromtxt(adresse_emprise)
    if(np.size(emp)==0):
        emp=emptmp
    else:
        emp=np.concatenate((emp,emptmp))

Emin=np.min(emp[:,0])
Emax=np.max(emp[:,0])
Nmin=np.min(emp[:,1])
Nmax=np.max(emp[:,1])

#Tant qu'a faire, on va arrondir a des valeurs entieres
Emin=int(Emin)
Emax=int(Emax)+1
Nmin=int(Nmin)
Nmax=int(Nmax)+1

print(str(Emin)+" "+str(Emax)+" "+str(Nmin)+" "+str(Nmax))

Emin=Emin-marge
Emax=Emax+marge
Nmin=Nmin-marge
Nmax=Nmax+marge

print(str(Emin)+" "+str(Emax)+" "+str(Nmin)+" "+str(Nmax))

#On ecrit dans l'ordre attendu par gdal 
femp=open(adresse_export_emprise,"w")
femp.write(str(Emin)+str("\n"))
femp.write(str(Nmax)+str("\n"))
femp.write(str(Emax)+str("\n"))
femp.write(str(Nmin)+str("\n"))
femp.close()


