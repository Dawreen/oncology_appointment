import os
import re
import random

def pathology_from_index(index):
    po = '0 0 0 0 0 0 1'
    gi = '0 1 0 0 0 0 0'
    ma = '0 0 0 0 1 0 0'
    gy = '0 0 0 1 0 0 0'
    gu = '0 0 1 0 0 0 0'
    em = '1 0 0 0 0 0 0'
    ot = '0 0 0 0 0 1 0'
    aux = ""

    if index == 1: 
        aux = po
    elif index == 2 or index == 3: 
        aux = gi
    elif index == 4 or index == 7 or index == 8 or index == 9 \
        or index == 13 or index == 14 or index == 15 or index == 16: 
        aux = ot
    elif index == 5: 
        aux = em
        bed = True
    elif index == 6: 
        aux = gu
    elif index == 10: 
        aux = gu
    elif index == 11: 
        aux = gy
    elif index == 12: 
        aux = ma

    return aux

def pathology_from_name(s):
    po = 'PO'
    gi = 'GI'
    ma = 'MA'
    gy = 'GY'
    gu = 'GU'
    em = 'EM'
    ot = 'OT'
    aux = ""
    if s == "a": 
        aux = po
    elif s == "b1" or s == "b2": 
        aux = gi
    elif s == "b3" or s == "e" or s == "f" or s == "g" \
        or s == "k" or s == "l" or s == "m" or s == "z": 
        aux = ot
    elif s == "c": 
        aux = em
    elif s == "d": 
        aux = gu
    elif s == "h": 
        aux = gu
    elif s == "i": 
        aux = gy
    elif s == "j": 
        aux = ma
    return aux

def macro_pathology(arg):
    # N a b1 b2 b3 c d e f g  h  i  j  k  l  m  z
    # 0 1  2  3  4 5 6 7 8 9 10 11 12 13 14 15 16
    args = re.split('\s', arg)
    args = list(filter(None, args))
    args[len(args)-1] = args[len(args)-1].replace(";", "")
    index = args.index("1", 1, len(args))
    
    return args[0] + "  " + pathology_from_index(index) + "\n"

def time_convertion(arg):
    args = re.split('\s', arg)
    args = list(filter(None, args))
    args[1] = str(int(args[1]) * 6)
    
    if "0.33" in args[2]:
        args[2] = "2"
    elif "0.167" in args[2]:
        args[2] = "1"
    return str(args[0]) + "     " + args[1] + "  " + args[2] + "\n"

def macro_room(arg):
    skip = False
    args = arg.replace("[", "")
    args = args.replace("]", "")
    args = args.replace(",", "")
    args = args.replace(";", "")

    args = re.split('\s', args)
    args = list(filter(None, args))

    if args[0] == "7":
        return ""
    
    if args[1] == "b2" or args[1] == "h" or args[1] == "e"\
        or args[1] == "f" or args[1] == "g" or args[1] == "k"\
        or args[1] == "l" or args[1] == "m" or args[1] == "z": 
        skip = True
    args[1] = pathology_from_name(args[1])

    if skip:
        return ""

    return "[" + args[0] + ", " + args[1] + ", " + args[2] + "] " + " " + args[3] + "\n"

# pi=poltrona  lambda=letto
def set_letto():
    return "      0 1\n"
def set_poltrona():
    return "      1 0\n"
def decision(p) -> bool:
    return random.random() < p
def poltrona_letto(x):
    ret = re.split('\s', x)
    ret = list(filter(None, ret))
    id_paziente = ret[0]
    is_EM = ret[5] == "1"
    if is_EM:
        if decision(0.35):
            return id_paziente + set_letto()
        else:
            return id_paziente + set_poltrona()
    else:
        if decision(0.85):
            return id_paziente + set_poltrona()
        else:
            return id_paziente + set_letto()

def put_semi(file):
    file.write(";\n")

def correct(f):
    f_read = open("ist_Lacommare/" + f, "r")
    f_write = open("ist_correct/" + "corr_" + f, "w+")

    if f_read.mode == 'r':
        fl = f_read.readlines()
        in_path = False
        in_time = False
        in_assegnamento = False
        semi = False
        str_pi_lam = ""

        for x in fl:
            if in_path:
                if ";" in x:
                    in_path = False
                    semi = True
                f_write.write(macro_pathology(x))
                str_pi_lam = str_pi_lam + poltrona_letto(x)
            
            if in_time:
                if ";" in x:
                    in_time = False
                    semi = True
                f_write.write(time_convertion(x))
            
            if in_assegnamento:
                if ";" in x:
                    in_assegnamento = False
                    semi = True
                f_write.write(macro_room(x))
            
            if semi:
                put_semi(f_write)
                semi = False

            if "param ptot" in x:
                f_write.write(x)

            if "set K" in x:
                f_write.write("set K := EM GI GU GY MA OT PO;\n")

            if "set T" in x:
                f_write.write(x)

            if "set L" in x:
                f_write.write("set A := 1 2 3 4 5 6;\n")

            if "param d" in x:
                f_write.write("param d := 36;\n")

            if "N" in x:
                f_write.write("param MaxPi := 26;\nparam MaxLambda := 27;\n")

            if "M2" in x:
                f_write.write("param M := 54;\n")
                f_write.write("param: pi lambda :=\n" + str_pi_lam + ";\n")

            if "param s:" in x:
                in_path = True
                f_write.write("param alpha: EM GI GU GY MA OT PO:=\n")
            if "param:" in x:
                in_time = True
                f_write.write("param:   f   v:=\n")
            if "param w" in x:
                in_assegnamento = True
                f_write.write("param    w:=\n")
    
    f_write.close()
    print("Correzione file " + f + " completata.")
    return

def main():
    for f in os.listdir("ist_Lacommare"):
        correct(f)

if __name__ == "__main__":
    main()