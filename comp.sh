path="data/pts/" 

cliche="IGNF_PVA_1-0__1996-07-15__C96SAA1462_1996_FD24_0779"


python comparaison.py  ${path}/${cliche}.ptsspg  ${path}/${cliche}.BDOrtho.ptsspg  ${path}/${cliche}.ptsreproj.aff.modelespg
python comparaison.py  ${path}/${cliche}.ptskaub  ${path}/${cliche}.BDOrtho.ptskaub  ${path}/${cliche}.ptsreproj.aff.modelekaub
