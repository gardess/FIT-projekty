#!/usr/bin/python3

#CHA:xgarda04

import sys
import io
import fileinput
import sys
import re
import os
import os.path
import copy

#-----------------------------------------------------------------------

# Funkce, která slouží k výpisu nápovědy
def printHelp():
    print("CHA - C Header Analysis")
    print("2. projekt do předmětu IPP")
    print("Autor: Milan Gardáš\n")
    print("Použití:")
    print("cha.py\t[--help|-h] [--input=path] [--output=filename] [--pretty-xml=k]\n\t[--no-inline] [--max-par=n] [--no-duplicates] [--remove-whitespaces]\n")
    print("Popis:\tSkript analyzuje hlavičkové soubory jazyka C a dle zadaných parametrů\n\tvytvoří databázi nalezených funkcí v těchto souborech\n")
    print("help\t\t   Zobrazí nápovědu")
    print("input\t\t   Zadaný vstupní soubor nebo adresář s *.h soubory jazyka C")
    print("output\t\t   Zadaný výstupní soubor ve formátu XML v kódování UTF-8")
    print("pretty-xml\t   Výstup bude zformátován tak, že každé nové zanoření bude\n\t\t   odsazeno o hodnotu parametru k, implicitně se k rovná 4")
    print("no-inline\t   Přeskočení funkcí se specifikátorem inline")
    print("max-par\t\t   Zpracování funkcí s n a méně parametry")
    print("no-duplicates\t   Pouze jeden výskyt každé funkce")
    print("remove-whitespaces Nahrazení bílých znaků mezerou a zároveň odstranění\n\t\t   přebytečných mezer")
    sys.exit(0)

#-----------------------------------------------------------------------
# Funkce, která slouží ke smazání blokových komentářů
# Param1: obsah souboru, ve kterém chceme mazat
# Return: obsah souboru bez blokových komentářů
def komentareBlokove(soubor):
    koment1 = ""
    maz = 0
    for i in range(len(soubor)):
        if (soubor[i] == "/" and soubor[i+1] == "*"):
            maz = 1
        elif (soubor[i-1] == "*" and soubor[i] == "/"):
            maz = 0
        elif (maz == 1):
            continue
        else:
            koment1 += soubor[i]
    return koment1

#-----------------------------------------------------------------------
# Funkce, která slouží ke smazání řádkových komentářů
# Param1: obsah souboru, ve kterém chceme mazat
# Return: obsah souboru bez řádkových komentářů
def komentareRadkove(koment1):
    maz = 0
    radek = 0
    koment2 = ""
    for i in range(len(koment1)):
        if (koment1[i] == "/" and koment1[i+1] == "/"):
            maz = 1
        elif (koment1[i] == "\\" and koment1[i+1] == "\n" and maz == 1):
            radek = 1
        elif (koment1[i] == "\n" and maz == 1):
            maz = 0
            if (radek == 1):
                radek = 0
                maz = 1
        elif (maz == 1):
            continue
        else:
            koment2 += koment1[i]
    return koment2

#-----------------------------------------------------------------------
# Funkce, která slouží ke smazání maker
# Param1: obsah souboru, ve kterém chceme mazat
# Return: obsah souboru bez maker
def smazMakro(koment2):
    maz = 0
    radek = 0
    makro = ""
    for i in range(len(koment2)):
        if (koment2[i] == "#"):
            maz = 1
        elif (koment2[i] == "\\" and koment2[i+1] == "\n" and maz == 1):
            radek = 1
        elif (koment2[i] == "\n" and maz == 1):
            maz = 0
            if (radek == 1):
                radek = 0
                maz = 1
        elif (maz == 1):
            continue
        else:
            makro += koment2[i]
    return makro

#-----------------------------------------------------------------------
# Funkce, která slouží ke smazání řetězců
# Param1: obsah souboru, ve kterém chceme mazat
# Return: obsah souboru bez řetězců
def smazRetezec(makro):
    maz = 0
    retezec1 = ""
    for i in range(len(makro)):
        if ((makro[i] == '"' and makro[i-1] == "\\") or (makro[i] == '\'' and makro[i-1] == "\\")):
            i = i + 2
            continue
        else:
            retezec1 += makro[i]

    maz = 0
    retezec2 = ""
    for i in range(len(retezec1)):
        if (((retezec1[i] == '"' and retezec1[i-1] != "\\") or (retezec1[i] == '\'' and retezec1[i-1] != "\\")) and maz == 0):
            maz = 1
        elif ((retezec1[i] == '"' or retezec1[i] == '\'') and maz == 1):
            maz = 0
        elif (maz == 1):
            continue
        else:
            retezec2 += retezec1[i]
    return retezec2

#-----------------------------------------------------------------------
# Funkce, která slouží ke smazání obsahu mezi složenými závorkami
# Param1: obsah souboru, ve kterém chceme mazat
# Return: obsah souboru bez složených závorek a obsahu mezi nimi
def smazTelo(retezec2):
    zavorka = 0
    definice = ""
    for i in range(len(retezec2)):
        if (retezec2[i] == '{'):
            zavorka = zavorka + 1
        elif (retezec2[i] == '}'):
            zavorka = zavorka - 1
            definice += ";"
            if (zavorka == 0):
                i = i + 1
        if (zavorka > 0):
            continue
        else:
            definice += retezec2[i]
    return definice

#-----------------------------------------------------------------------
# Funkce, která slouží ke smazání slov - typedef, struct, union, enum 
# Param1: obsah souboru, ve kterém chceme mazat
# Return: obsah souboru bez výše uvedených slov
def smazSlova(hlav):
    for i in range(len(hlav)):
        for j in range(len(hlav[i])):
            if (hlav[i][j] == "t" and hlav[i][j+1] == "y" and hlav[i][j+2] == "d" and hlav[i][j+3] == "e" and hlav[i][j+4] == "d" and hlav[i][j+5] == "e" and hlav[i][j+6] == "f"):
                hlav[i] == ""
            elif (hlav[i][j] == "s" and hlav[i][j+1] == "t" and hlav[i][j+2] == "r" and hlav[i][j+3] == "u" and hlav[i][j+4] == "c" and hlav[i][j+5] == "t"):
                hlav[i] == ""
            elif (hlav[i][j] == "u" and hlav[i][j+1] == "n" and hlav[i][j+2] == "i" and hlav[i][j+3] == "o" and hlav[i][j+4] == "n"):
                hlav[i] == ""
            elif (hlav[i][j] == "e" and hlav[i][j+1] == "n" and hlav[i][j+2] == "u" and hlav[i][j+3] == "m"):
                hlav[i] == ""
    # Mazání prázdných řádků
    prazdny = 0
    for i in range(len(hlav)):
        if (hlav[i] == ''):
            prazdny += 1
    while(prazdny != 0):
        hlav.remove('')
        prazdny -= 1
    return hlav

#-----------------------------------------------------------------------
# Funkce slouží ke smazání komentářů, maker, řetězců, těl funkcí ze souboru z parametru a následně vybírá jednotlivé hlavičky funkcí
# Param1: obsah souboru či souborů zadaných parametrem input
# Return: seznam hlaviček funkcí 
def mazani(soubor):
    koment1 = komentareBlokove(soubor) # Smazání komentářů typu /* */
    koment2 = komentareRadkove(koment1) # Smazání komentářů typu //
    makro = smazMakro(koment2) # Smazání maker
    retezec = smazRetezec(makro) # Smazání řetězců
    definice = smazTelo(retezec) # Smazání těl funkcí

    # Regulární výraz, který vybírá ze souboru hlavičky funkcí
    hlavicka = re.compile('[a-zA-Z_][a-zA-Z0-9_*\s]*[(][a-zA-Z0-9_,.*\s]*[)][\s]*[;]')
    hlav = hlavicka.findall(definice)

    hlavv = smazSlova(hlav) # Hledání klíčových slov typedef, enum, struct, union
    return hlavv
    
#-----------------------------------------------------------------------
# Funkce rozděluje hlavičku funkce na jednotlivé elementy, a následně je vypisuje
# Param1: jedna hlavička funkce
# Param2: soubor, do kterého probíhá zápis
# Param3: název souboru, ze kterého pochází aktuální hlavička funkce
# Param4: seznam sloužící k uchování jmen funkcí aktuálního souboru
# Param5: slouží pro kontrolu, zda byl zadán parametr --pretty-xml, může nabývat pouze hodnot 0 a 1
# Param6: hodnota parametru --pretty-xml
# Param7: slouží pro kontrolu, zda byl zadán parametr --no-inline, může nabývat pouze hodnot 0 a 1
# Param8: slouží pro kontrolu, zda byl zadán parametr --no-duplicates, může nabývat pouze hodnot 0 a 1
# Param9: slouží pro kontrolu, zda byl zadán parametr --remove-whitespace, může nabývat pouze hodnot 0 a 1
# Param10: slouží pro kontrolu, zda byl zadán parametr --max-par, může nabývat pouze hodnot 0 a 1
# Param11: hodnota parametru --max-par
def rezani(func, out, nazev, funkce, prettyParam, prettyParams, inlineParam, duplicatesParam, whiteParam, maxParam, maxParams):
    
    # Parametr --no-inline
    if (inlineParam == 1):
        inlineRV1 = re.compile('inline[\s]+') # je na začátku funkce
        inlineRV2 = re.compile('[\s]+inline[\s]+') # není na začátku funkce
        pom1 = inlineRV1.findall(func)
        pom2 = inlineRV2.findall(func)
        if ((len(pom1)) != 0 or (len(pom2)) != 0):
            return 0
    # Úprava hlavičky pro lepší zpracování    
    levaZavorka = re.compile('\s*[(]\s*')
    pravaZavorka = re.compile('\s*[)]\s*')
    carka = re.compile('\s*[,]\s*')
    func = levaZavorka.sub('(',func)
    func = pravaZavorka.sub(')',func)
    func = carka.sub(',',func)
    
    mezera = re.compile('\s\s+')
    hvezda = re.compile('\s*[*]\s*')
    # Parametr --remove-whitespace
    if (whiteParam == 1):
        func = mezera.sub(' ',func)
        func = hvezda.sub('*',func)
    
    # Získání jména funkce
    jmenoFunkce = re.compile('[a-zA-Z_][a-zA-Z0-9_]*[(]') #[\s][a-zA-Z_][a-zA-Z0-9_]*[(]
    jmeno = jmenoFunkce.findall(func)
    jmeno = levaZavorka.sub('',jmeno[0])
    
    # Parametr --no-duplicates
    if (duplicatesParam == 1):
        kopie = copy.copy(jmeno)
        for i in range(len(funkce)):
            if (kopie == funkce[i]):
                return 0
        funkce.append(kopie)
    
    # Odmazání jména funkce z hlavičky
    func = jmenoFunkce.sub('(',func)
    func = levaZavorka.sub('(',func)

    # Získání návratového typu funkce
    navratovyTyp = re.compile('[a-zA-Z_][a-zA-Z0-9_*\s]*[(]')
    navrat = navratovyTyp.findall(func)
    navrat = levaZavorka.sub('',navrat[0])

    # Odmazání návratového typu funkce z hlavičky
    strednik = re.compile('\s*[)][;]\s*')
    func = navratovyTyp.sub('(',func)
    func = levaZavorka.sub('',func)
    func = strednik.sub('',func)

    # Získání parametrů funkcí
    parametry = re.compile('[a-zA-Z_][a-zA-Z0-9_*\s]*[\s|*]')
    parametryTypy = parametry.findall(func)
    zacatek = re.compile('^\s+')
    konec = re.compile('\s+$')
    for i in range(len(parametryTypy)):
        parametryTypy[i] = zacatek.sub('',parametryTypy[i])
        parametryTypy[i] = konec.sub('',parametryTypy[i])

    # Zjištění, zda funkce má nebo nemá proměnný počet parametrů
    pomoc = carka.split(func)
    mazRadek = re.compile('.*')
    pocetParametru = 0
    promenneParametry = ""
    for i in range(len(pomoc)):
        pocetParametru = len(pomoc)
        promenneParametry = "no"
        if (pomoc[i] == "" or pomoc[i] == "void"):
            pocetParametru = 0
        elif (pomoc[i] == "..."):
            pocetParametru -= 1
            promenneParametry = mazRadek.sub('',promenneParametry)
            promenneParametry = "yes"
    
    # Parametr --max-par
    if (maxParam == 1 and pocetParametru > maxParams):
        return 0
    

    # Výpis
    if (prettyParam == 1):
        it = 0
        while (it != (prettyParams)):
            out.write(" ")
            it = it + 1
    out.write("<function file=\""+nazev+"\" name=\""+str(jmeno)+"\" varargs=\""+str(promenneParametry)+"\" rettype=\""+str(navrat)+"\">")
    iterat = 1
    while (iterat != (pocetParametru+1)):
        if (prettyParam == 1):
            out.write("\n")
            it = 0
            while (it != (2*prettyParams)):
                out.write(" ")
                it = it + 1
        out.write("<param number=\""+str(iterat)+"\" type=\""+parametryTypy[iterat-1]+"\" />")
        iterat += 1
    
    if (prettyParam == 1):
        out.write("\n")
        it = 0
        while (it != (prettyParams)):
            out.write(" ")
            it = it + 1
    out.write("</function>")
    if (prettyParam == 1):
        out.write("\n")
    
    return 0

#-----------------------------------------------------------------------
# Proměnné pro zjištění, které parametry byly zadány
inputParam = 0
outputParam = 0
prettyParam = 0
inlineParam = 0
maxParam = 0
duplicatesParam = 0
whiteParam = 0
prettyParams = 0
wrongParam = 0

inputParams = "./"
outputParams = ""
maxParams = 0

#-----------------------------------------------------------------------

# Zpracování parametrů příkazové řádky
for key in sys.argv[1:]:
    if (key == "--help" and (len(sys.argv) == 2)):
        printHelp()
    elif (key == "--help" and (len(sys.argv) != 2)):
        sys.stderr.write("Parametr --help nebyl zadán samostatně.\n")
        sys.exit(1)
    elif (key[0:8] == "--input="):
        inputParam = inputParam + 1
        inputParams = key[8:]
    elif (key[0:9] == "--output="):
        outputParam = outputParam + 1
        outputParams = key[9:]
    elif (key[0:13] == "--pretty-xml="):
        prettyParam = prettyParam + 1
        prettyParams = key[13:]
        if (prettyParams.isnumeric() == False):
            sys.stderr.write("Špatně zadaný parametr --pretty-xml.\n")
            sys.exit(1)
        prettyParams = int(prettyParams)
    elif (key[0:12] == "--pretty-xml"):
        prettyParam = prettyParam + 1
        prettyParams = 4
    elif (key == "--no-inline"):
        inlineParam = inlineParam + 1
    elif (key[0:10] == "--max-par="):
        maxParam = maxParam + 1
        maxParams = key[10:]
        if (maxParams.isnumeric() == False):
            sys.stderr.write("Špatně zadaný parametr --max-par.\n")
            sys.exit(1)
        maxParams = int(maxParams)
    elif (key == "--no-duplicates"):
        duplicatesParam = duplicatesParam + 1
    elif (key == "--remove-whitespace"):
        whiteParam = whiteParam + 1
    else:
        wrongParam = wrongParam + 1

# Kontrola toho zda nebyl některý parametr zadán dvakrát nebo nebyl zadán neznámý parametr
if ((inputParam > 1) or (outputParam > 1) or (prettyParam > 1) or (inlineParam > 1) or (maxParam > 1) or (duplicatesParam > 1) or (whiteParam > 1) or (wrongParam > 0)):
    sys.stderr.write("Některý parametr byl zadán vícekrát nebo byl zadán neznámý parametr.\n")
    sys.exit(1)

#-----------------------------------------------------------------------
# Získání seznamu vstupních souborů
cestareal = []
koren = []
souborys = []
soub = []
if (os.path.isdir(inputParams)): # Je zadán adresář nebo nebyl zadán parametr input
    for root, dirs, files in os.walk(inputParams):
        koren.append(root)
        souborys.append(files)
        
    oddelovac = ['/']
    for i in range(len(souborys)):
        for j in range(len(souborys[i])):
            if (i == 0):
                temp = koren[i] + souborys[i][j]
            else:
                temp = koren[i] + oddelovac[0] + souborys[i][j]
            if (temp[-2:] == ".h"):
                soub.append(temp)

    
    for i in range(len(soub)):
        cestareal.append(os.path.relpath(soub[i], inputParams))

else: # Je zadán soubor
    cestareal += [inputParams]
    inputParams=""

#-----------------------------------------------------------------------
# Otevření výstupního souboru, za předpokladu jeho zadání 
if (outputParam == 1): # zadán parametr --output
    out = sys.stdout
    try:
        out = open(outputParams, "w", encoding="utf8")
    except:
        sys.stderr.write("Výstupní soubor se nepořilo otevřít.")
        sys.exit(3)
else:
    out = sys.stdout

#-----------------------------------------------------------------------
# Část výpisu
out.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>")
if (prettyParam == 1):
    out.write("\n")
out.write("<functions dir=\""+inputParams+"\">")
if (prettyParam == 1):
    out.write("\n")

for nazev in cestareal:
    try:
        soub=open(os.path.join(inputParams,nazev),"r").read()
    except:
        sys.stderr.write("Nepodařilo se otevřít vstupní soubor.\n")
        sys.exit(2)
    
    radky = mazani(soub)
    funkce = []
    for hlavicka in radky:
        rezani(hlavicka, out, nazev, funkce, prettyParam, prettyParams, inlineParam, duplicatesParam, whiteParam, maxParam, maxParams)
        
    # Smazání obsahu seznamu funkcí
    iterpom = 0
    promm = len(funkce)
    while(iterpom != promm):
        funkce.pop()
        iterpom += 1

out.write("</functions>")
out.write("\n")

