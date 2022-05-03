# INSIEMI E PARAMETRI

set Pvisitati default {} ;   # pazienti visitati
set Pnonvisitati default {}; # pazienti non visitati
param GV{Pvisitati} within T;# GV[p]=giorno di visita del paziente visitato p

# VARIABILI

var C{P} >=0 ; 
# tempo di permanenza del paziente p nel centro

# FUNZIONE OBIETTIVO

minimize TempoPermanenza: sum{p in P} C[p] ;
# mimimizzare il tempo di permanenza dei pazienti in ospedale

# VINCOLI

subject to C10 {p in P, t in T}:
    (sum{h in H} (h+f[p])*y[p,t,h]) - (sum{h in 1..d, a in A} h*x[p,t,h,a]) <= C[p] ;
# il tempo di permanenza in ospedale nel giorno t 
# e' dato dal tempo di fine infusione meno il tempo di inizio visita

subject to C11 {p in Pnonvisitati, t in T, a in A, h in 1..d}: 
	x[p,t,h,a] = 0 ;
    
subject to C12 {p in Pnonvisitati, t in T, h in H}: 
	y[p,t,h] = 0 ;

subject to C13 {p in Pvisitati, t in T: GV[p]=t}: 
	sum{a in A, h in 1..d} x[p,t,h,a] = 1 ;
    
subject to C14 {p in Pvisitati, t in T: GV[p]=t}: 
	sum{h in H} y[p,t,h] = 1 ;

subject to C15 {p in Pvisitati, a in A, h in 1..d, t in T: GV[p]<>t}: 
	x[p,t,h,a] = 0 ;

subject to C16 {p in Pvisitati, a in A, h in H, t in T: GV[p]<>t}: 
	y[p,t,h] = 0 ;
