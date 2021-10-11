set PATH; # set of pathologies
set CLIN; # set of clinicians
set ACES; # set of accessi
set ROOM = 1 .. 8; # set of rooms
set DAYS = 1 .. 5; # set of days
set LDAY = 1 .. 21; # set of monthly planning

set BLOCK {DAYS, ROOM};

param capacity {BLOCK};

param ID_path {PATH};
param CodK {PATH} symbolic;
param MainCatK {PATH} symbolic; # to consider when assigning room to pathology
param visit_time {PATH};
param infusion_time {PATH};
param DescrizioneK {PATH} symbolic;

param NOME {CLIN} symbolic;
# skills
param KAPPA1 {CLIN} symbolic;
param KAPPA2 {CLIN} symbolic;
# working days in the week
param LUN {CLIN} binary;
param MAR {CLIN} binary;
param MER {CLIN} binary;
param GIO {CLIN} binary;
param VEN {CLIN} binary;
# TODO: create data to import from
param available {CLIN, LDAY} binary;

param ID_accesso {ACES};
param ID_paziente {ACES};
param KAPPA_1 {ACES} symbolic;
param KAPPA_2 {ACES} symbolic;
param KAPPA_3 {ACES} symbolic;
param KAPPA_4 {ACES} symbolic;
param Settimana {ACES};
param Mese {ACES};
param farmaco1 {ACES} symbolic; 
param reparto {ACES} symbolic;
param data_prevista {ACES} symbolic;
param data_allestimento {ACES} symbolic;
param farmaco2 {ACES} symbolic;
#TODO: create data to import from
param p {LDAY, DAYS}
# equal to 1 if day g in LDAY occurs on working day d in DAYS

# - Per la chemioterapia (infusione) ci sono a disposizione 27 letti 
#   (principalmente dedicati ai pazienti ematologici) e 26 poltrone.
# - Gli ambulatori sono 8, di cui 3 dedicati alle visite dei pazienti 
#   oncologici (MacroK da 2 a 7), 1 per le urgenze (ambulatorio dedicato 
#   con medico dedicato) più altri 4 ambulatori per i pazienti ematologici. 
#   Gli 8 ambulatori sono aperti 5 giorni a settimana, per 6 ore al giorno
#   dalle 8 alle 14.

# Le sale infusione possono rimanere aperte fino alle 15? 16? Si potrebbe 
# verificare cosa cambia variando l’orario di chiusura.

var x {DAYS, ROOM, PATH} binary; 
    # 1 if block b = (d, k) is reserved for pathology j, with d in D, k in K
    # 0 otherwise
var w {LDAY, ROOM, CLIN, PATH} binary;
    # 1 if clinician i treats pathology j in day g in G and room k in K
    # 0 otherwise
var u {LDAY, CLIN} binary;
    # 1 if clinician i covers the urgency ambulatory in day g in G
    # 0 otherwise
var v {LDAY, CLIN} binary;
    # 1 if clinician i covers the continuity of care ambulatory in day g in G
    # 0 otherwise

var beta {LDAY, ROOM, PATH} >= 0;
    # overtime visits

var lamgda;
    # maximum workload

var z;
    # maximum unmet demand

var m {PATH};
    # the weekly highest number of request for pathologies


subject to Constraint1 {d in DAYS, k in ROOM}: # 1
    sum {j in PATH} x[d, k, j] = 1
    # each block (d, k) is assigned to one and only one pathology
;

subject to Constraint2 {j in PATH}: # 2
    sum{d in DAYS, k in ROOM} capacity[d, k, j] * x[d, k, j] + beta[d, k, j] >= l[j]
    # the blocks allocated to a pathology j in a week are sufficient to deal 
    # with the weekly reference demand, possibly with some overtime visits, 
    # represented by variables beta[d, k, j]
;

subject to Constraint3 {j in PATH, d in DAYS, k in ROOM}: # 3
    beta[d, k, j] <= M * x[d, k, j]
    # overtime visits for a pathology can be activated in a block only if 
    # the pathology is assigned to the block
;

subject to Constraint4 {j in PATH, d in DAYS, g in LDAY, i in CLIN}: # 4
    if (skill[i, j] == 1 && available[i, g] == 1) x[d, k, j] <= 1
# k in K: p[g, d] equal to 1 if day g in LDAY occurs on working day d in DAYS
# s[i, j] = a[i, g] = 1 =>clinician has the skill and is available
;

subject to Constraint5 {j in PATH, d in DAYS, g in LDAY, k in ROOM}: # 5
    if (p[g, d] == 1) x[d, k, j] = sum{i in CLIN} w[g, k, i, j] 
# k in K: p[g, d] equal to 1 if day g in LDAY occurs on working day d in DAYS
;

subject to Constraint6 {g in LDAY}: # 6
    sum{i in CLIN} u[g, i] = 1
;
subject to Constraint7 {g in G}: # 7
    sum{i in CLIN} v[g, i] = 1
    # (6) and (7) guarantee that the urgency and the continuity of care
    # services are covered and assigned to a clinician in each day
;

subject to Constraint8 {i in CLIN, g in LDAY}: # 8
    sum{j in PATH, k in ROOM} w[g, k, i, j] + u[g, i] + v[g, i] <= avail[i, j]
    # forbid a clinician to be assigned to any services or ambulatories in 
    # day g if he/she is not available
;

subject to Constraint9 {i in CLIN, g in LDAY-1}: # 9 pag.70 per condizione simile
    if (p[g,5] == 0) v[g, i] + u[g+1, i] + v[g+1, i] + sum {j in PATH, k in ROOM} w[g, k, i, j] <= 1
# j in PATH: s[i, j] = 1
# ∀i ∈ I, g ∈ G ∶ (g + 1) ∈ G, pg5 = 0
;

subject to Constraint10 {i in CLIN}: #10
    lamgda => sum {j in PATH, g in LDAY, k in ROOM} w[g, k, i, j] +
              sum {g in LDAY} (u[g, i] + v[g, i] 
              )
;

subject to Constraint11 {i in CLIN, j in PATH}: # 11
    z => 100 * (m[j] - sum {b in BLOCK} capacity[d, k, j] * x[d, k, j]) / m[j]


# TODO: h1, h2, h3??

# Multi-criteria model 12: subject to (1) - (11)
minimize Lexicographic_Objcetive:
    h1 * sum{j in PATH, d in DAYS, k in ROOM} 
    beta[d, k, j] + h2 * lamgda * h3 * z
;

# FEASibility 13: subject to (1) - (9)
minimize FEAS:
    sum{j in PATH, d in DAYS, k in ROOM} beta[d, k, j]
;

# TODO: beta_optimal 14

# workLOAD 15: subject to (1) - (10), (14)
minimize LOAD: lamgda;

# FAIRness 16: s.t.(1) − (9),(11),(14)
minimize FAIR: z;

# FAIRness and balanced Maximum workLOAD
# minimize FAIR_ML: 17
# TODO: 18 s.t. (1) − (9),(11),(14)
# TODO: 19
# TODO: 20