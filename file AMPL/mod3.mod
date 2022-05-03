# INSIEMI E PARAMETRI

param TP >=0 ;
# tempo di permanenza totale

# FUNZIONE OBIETTIVO

maximize PrefPoltrona: sum{p in P, t in T, h in H: pi[p]=1} zP[p,t,h] ;
# massimizzare il numero di pazienti (assegnati alle poltrone) che fanno l'infusione nelle poltrone

# VINCOLI

subject to Ctempoperm: sum{p in P} C[p] <= TP ;
# il tempo di permanenza totale in ospedale <= tempo "ottimo" trovato risolvendo il problema 2
