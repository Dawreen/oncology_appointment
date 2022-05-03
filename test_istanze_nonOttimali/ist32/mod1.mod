# INSIEMI E PARAMETRI

param ptot; # numero totale pazienti
set P = 1 .. ptot; # insieme pazienti

set K; # insieme patologie
set T; # insieme dei giorni lavorativi in una settimana
param d; # numero di slot in cui e' aperto l'ambulatorio (8-14)

param M; # numero di slot in cui e' aperto il servizio (8-17)
set H := 1..M; # insieme timeslot di un giorno (8-17)

set A; # insieme ambulatori
param alpha{P, K} binary; # 1 se il paziente p ha la patologia k
param pi{P} binary; # 1 se il paziente p è assegnato ad una poltrona
param lambda{P} binary; # 1 se il paziente p è assegnato ad un letto
param v{P}; # durata visita del paziente p
param f{P}; # durata infusione del paziente p
param w{A, K, T} binary; 
# 1 se la patologia k è assegnata all'ambulatorio a nel giorno t
param MaxPi; # massimo numero di poltrone 26
param MaxLambda; # massimo nuemro di letti 27

# VARIABILI

var x{P, T, 1..d, A} binary;
# x[p,t,h,a]=1 se paziente p inizia la visita nell'ambulatorio a all'istante h del giorno t

var y{P, T, H} binary; 
# y[p,t,h]=1 se paziente p inizia l'infusione all'istante h del giorno t

var zL{p in P, T, H: pi[p]=1} binary;
# zL[p,t,h]=1 se paziente p inizia l'infusione all'istante h nel giorno t in un letto
# zL[p,t,h]=0 altrimenti

var zP{p in P, T, H: pi[p]=1} binary;
# zP[p,t,h]=1 se paziente p inizia l'infusione all'istante h nel giorno t in una poltrona
# zP[p,t,h]=0 altrimenti

# FUNZIONE OBIETTIVO

maximize NumeroVisite: sum{p in P, t in T, h in 1..d, a in A} x[p,t,h,a] ;
# massimizzare il numero di persone visitate e sottoposte a infusione

# VINCOLI

subject to C1 {p in P}:
    sum{a in A, t in T, h in 1..d} x[p,t,h,a] <= 1 ;
# ogni paziente può essere visitato al più una volta nella settimana

subject to C2 {p in P, t in T}:
    sum{a in A, h in 1..d} x[p,t,h,a] = sum{h in H} y[p,t,h] ;
# la visita e l'infusione devono avvenire lo stesso giorno

subject to C3 {p in P, t in T}:
    sum{a in A, h in 1..d} ((h+v[p])*x[p,t,h,a]) <= sum{h in H} h*y[p,t,h] ;
# l'infusione deve avvenire dopo la visita

subject to C4 {t in T, h in H}:
    sum{p in P, q in 1..h: pi[p]=1 and q >= h+1-f[p]} zP[p,t,q] <= MaxPi ;
# non si può superare il numero massimo di poltrone

subject to C5 {t in T, h in H}:
    sum{p in P, q in 1..h: lambda[p]=1 and q >= h+1-f[p]} y[p,t,q] + sum{p in P, q in 1..h: pi[p]=1 and q >= h+1-f[p]} zL[p,t,q] <= MaxLambda ;
# non si può superare il numero massimo di letti

subject to C6 {p in P, t in T, a in A}: 
	sum{h in 1..d} (h-1+v[p])*x[p,t,h,a] <= d ;
# le visite devono finire prima della chiusura dell'ambulatorio

subject to C7 {p in P, t in T}:
    sum{h in H} (h-1+f[p])*y[p,t,h] <= M ;
# le infusioni devono finire prima della chiusura del servizio

subject to C8 {p in P, t in T, a in A, k in K: alpha[p,k]=1}:
    sum{h in 1..d} x[p,t,h,a] <= w[a,k,t] ;
# il paziente p deve essere curato in un ambulatorio a designato per la patologia

subject to C9 {a in A, t in T, h in 1..d}:
	sum{p in P, q in 1..h: q >= h+1-v[p]} x[p,t,q,a] <= 1 ;
# ogni ambulatorio puo' visitare max una persona alla volta

subject to CPL {p in P, t in T, h in H: pi[p]=1}:
	y[p,t,h] = zL[p,t,h] + zP[p,t,h] ;
# ogni paziente assegnato ad una poltrona può fare l'infusione o in una poltrona o in un letto

