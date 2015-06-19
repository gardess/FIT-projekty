--------------------------------------------------------------------------------
-- Smazání tabulek a sekvencí databáze

DROP TABLE Akademicky_Pracovnik CASCADE CONSTRAINTS;
DROP TABLE Predmet CASCADE CONSTRAINTS;
DROP TABLE AP_Predmet CASCADE CONSTRAINTS;
DROP TABLE Ucebna CASCADE CONSTRAINTS;
DROP TABLE Rezervace CASCADE CONSTRAINTS;
DROP TABLE Vybaveni_Ucebny CASCADE CONSTRAINTS;
DROP TABLE Jednorazova CASCADE CONSTRAINTS;
DROP TABLE Pravidelna CASCADE CONSTRAINTS;

DROP SEQUENCE Citac_Vybaveni;

--------------------------------------------------------------------------------
-- Vytvoøení tabulek databáze

CREATE TABLE Akademicky_Pracovnik(
Rodne_Cislo NUMBER(10) CONSTRAINT PK_Akademicky_Pracovnik PRIMARY KEY,
Jmeno VARCHAR2(20) NOT NULL,
Prijmeni VARCHAR2(20) NOT NULL,
Titul VARCHAR2(20) NOT NULL,
Datum_Narozeni DATE,
Pohlavi VARCHAR2(4) NOT NULL,
Adresa VARCHAR2(50) NOT NULL,
Ustav VARCHAR2(30) NOT NULL,

CHECK (REGEXP_LIKE(Rodne_Cislo, '[0-9]{2}(0[1-9]|1[0-2]|5[1-9]|6[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[0-9]{4}') AND MOD(Rodne_Cislo, 11) = 0)
);

CREATE TABLE Predmet(
Zkratka VARCHAR2(4) CONSTRAINT PK_Predmet PRIMARY KEY,
Nazev VARCHAR2(50) NOT NULL,
Garant VARCHAR2(30) NOT NULL,
Hodinova_Dotace NUMBER(1,0) NOT NULL,
Typ VARCHAR2(3) NOT NULL,
Semestr VARCHAR2(5) NOT NULL,
Zakonceni VARCHAR2(4) NOT NULL,
Pocet_Kreditu NUMBER(2,0) NOT NULL
);

CREATE TABLE AP_Predmet(
Rodne_Cislo NUMBER(10) CONSTRAINT FK_Akademicky_Pracovnik REFERENCES Akademicky_Pracovnik (Rodne_Cislo),
Zkratka VARCHAR2(4) CONSTRAINT FK_Predmet REFERENCES Predmet (Zkratka),
Od DATE NOT NULL,
Do DATE NOT NULL,
Role_AP VARCHAR2(20) NOT NULL
);

CREATE TABLE Ucebna(
Oznaceni VARCHAR2(4) PRIMARY KEY,
Cislo_Mistnosti NUMBER(3, 0) NOT NULL,
Budova VARCHAR2(1) NOT NULL,
Pocet_Mist NUMBER(3, 0) NOT NULL
);

CREATE TABLE Rezervace(
Oznaceni VARCHAR2(4) CONSTRAINT FK_Ucebna REFERENCES Ucebna (Oznaceni),
Rodne_Cislo NUMBER(10) CONSTRAINT FK_AP_Rezervace REFERENCES Akademicky_Pracovnik (Rodne_Cislo),
Zkratka VARCHAR2(4) CONSTRAINT FK_Predmet_Rezervace REFERENCES Predmet (Zkratka),
Oznaceni_Ucebny VARCHAR2(4) NOT NULL,
Akademicky_Pracovnik VARCHAR2(30) NOT NULL,
Jednorazova CHAR(1) NOT NULL
);

-- Sekvence pro jedineèná inventární èísla
CREATE SEQUENCE Citac_Vybaveni START WITH 1 INCREMENT BY 1 NOMAXVALUE;


CREATE TABLE Vybaveni_Ucebny(
Inventarni_Cislo INTEGER NOT NULL PRIMARY KEY,
Nazev_Polozky VARCHAR2(50)  NOT NULL,
Urceni VARCHAR2(30),
Porizovaci_Cena NUMBER(8, 2)  NOT NULL,
Datum_Porizeni DATE NOT NULL,
Mistnost VARCHAR2(4) CONSTRAINT FK_Ucebna_Vybaveni REFERENCES Ucebna (Oznaceni)
);

CREATE TABLE Jednorazova(
Oznaceni VARCHAR2(4) CONSTRAINT FK_Ucebna_Jednorazova REFERENCES Ucebna (Oznaceni),
Rodne_Cislo NUMBER(10) CONSTRAINT FK_AP_Rezervace_Jedno REFERENCES Akademicky_Pracovnik (Rodne_Cislo),
Zkratka VARCHAR2(4) CONSTRAINT FK_Predmet_Rezervace_Jedno REFERENCES Predmet (Zkratka),
Den DATE NOT NULL,
Cas VARCHAR2(5) NOT NULL
);
CREATE TABLE Pravidelna(
Oznaceni VARCHAR2(4) CONSTRAINT FK_Ucebna_Pravidelna REFERENCES Ucebna (Oznaceni),
Rodne_Cislo NUMBER(10) CONSTRAINT FK_AP_Rezervace_Pravi REFERENCES Akademicky_Pracovnik (Rodne_Cislo),
Zkratka VARCHAR2(4) CONSTRAINT FK_Predmet_Rezervace_Pravi REFERENCES Predmet (Zkratka),
Semestr VARCHAR2(5) NOT NULL,
Tyden VARCHAR2(1) NOT NULL,
Den DATE NOT NULL,
Cas VARCHAR2(5) NOT NULL
);

--------------------------------------------------------------------------------
-- Úprava nìkterých tabulek

ALTER TABLE AP_Predmet ADD(CONSTRAINT PK_AP_Predmet PRIMARY KEY (Rodne_Cislo, Zkratka));
ALTER TABLE Rezervace ADD(CONSTRAINT PK_Rezervace PRIMARY KEY (Oznaceni, Rodne_Cislo, Zkratka));
ALTER TABLE Jednorazova ADD(CONSTRAINT PK_Jednorazova PRIMARY KEY (Oznaceni, Rodne_Cislo, Zkratka));
ALTER TABLE Pravidelna ADD(CONSTRAINT PK_Pravidelna PRIMARY KEY (Oznaceni, Rodne_Cislo, Zkratka));
ALTER TABLE Rezervace ADD(CONSTRAINT Typ_Rezervace CHECK(jednorazova in ('A', 'N')));

--------------------------------------------------------------------------------
-- Vložení hodnot do tabulek

INSERT INTO Akademicky_Pracovnik (Rodne_Cislo, Jmeno, Prijmeni, Titul, Datum_Narozeni, Pohlavi, Adresa, Ustav) VALUES('9009213939', 'Al', 'Koholik', 'Ing.', TO_DATE('21.9.1990', 'DD.MM.YY'), 'Muz', 'Evolucni 91, Kostice', 'Informacni systemy');
INSERT INTO Akademicky_Pracovnik (Rodne_Cislo, Jmeno, Prijmeni, Titul, Datum_Narozeni, Pohlavi, Adresa, Ustav) VALUES('7652053937', 'Denisa', 'Testová', 'Mgr.', TO_DATE('5.2.1976', 'DD.MM.YY'), 'Zena', 'Testova 91, Praha', 'Informacni systemy');
INSERT INTO Akademicky_Pracovnik (Rodne_Cislo, Jmeno, Prijmeni, Titul, Datum_Narozeni, Pohlavi, Adresa, Ustav) VALUES('5408252938', 'Michal', 'Barta', 'Ph.D.', TO_DATE('25.8.1954', 'DD.MM.YY'), 'Muz', 'Snová 1, Brno', 'Inteligentni systemy');
INSERT INTO Akademicky_Pracovnik VALUES ('7404162931', 'Stanislav', 'Esterka', 'Bc.', TO_DATE('16.04.1978', 'DD.MM.YY'), 'Muz', 'Kotlarska 19, Brno', 'Pocitacove systemy');
INSERT INTO Akademicky_Pracovnik VALUES ('7710110012', 'Michal', 'Krejèí', 'Prof.', TO_DATE('11.10.1977'), 'Muz', 'Hlavní 55, Pardubice', 'Inteligentni systemy');

INSERT INTO Predmet VALUES ('IDS', 'Databazove systemy', 'Pavel Hort', '3', 'P', 'L', 'ZaZk', '5');
INSERT INTO Predmet VALUES ('IIPD', 'Inzenyrska pedagogika a didaktika', 'Martin Maleèík', '4', 'V', 'O', 'Zk', '5');
INSERT INTO Predmet VALUES ('ICP', 'Seminar C++', 'Ondøej Sadílek', '2', 'PVT', 'L', 'Za', '3');

INSERT INTO AP_Predmet VALUES ('7404162931', 'IDS', TO_DATE('16.04.1978', 'DD.MM.YY'), TO_DATE('16.05.1978', 'DD.MM.YY'), 'Prednasejici');
INSERT INTO AP_Predmet VALUES ('9009213939', 'IIPD', TO_DATE('16.04.1978', 'DD.MM.YY'), TO_DATE('16.05.1978', 'DD.MM.YY'), 'Cvicici');
INSERT INTO AP_Predmet VALUES ('7652053937', 'ICP', TO_DATE('16.04.1978', 'DD.MM.YY'), TO_DATE('16.05.1978', 'DD.MM.YY'), 'Prednasejici');

INSERT INTO Ucebna VALUES ('D105', '105', 'D', '300');
INSERT INTO Ucebna VALUES ('E105', '10', 'E', '72');
INSERT INTO Ucebna VALUES ('N105', '255', 'N', '20');

INSERT INTO Vybaveni_Ucebny VALUES (Citac_Vybaveni.nextval, 'Projektor', 'K promitani', '150000,00', TO_DATE('15.12.2010', 'DD.MM.YY'), 'D105');
INSERT INTO Vybaveni_Ucebny VALUES (Citac_Vybaveni.nextval, 'Tabule', 'Ke psani', '010000,00', TO_DATE('1.1.2007', 'DD.MM.YY'), 'D105');
INSERT INTO Vybaveni_Ucebny VALUES (Citac_Vybaveni.nextval, 'Zidle', 'K sezeni', '002000,00', TO_DATE('8.6.2009', 'DD.MM.YY'), 'E105');
INSERT INTO Vybaveni_Ucebny VALUES (Citac_Vybaveni.nextval, 'Projektor', 'K promitani', '050000,00', TO_DATE('23.10.2014', 'DD.MM.YY'), 'N105');

INSERT INTO Rezervace VALUES ('D105', '7404162931', 'IDS', 'D105', 'Stanislav Esterka', 'A');
INSERT INTO Rezervace VALUES ('E105', '9009213939', 'IIPD', 'E105', 'Al Koholik', 'N');
INSERT INTO Rezervace VALUES ('E105', '7652053937', 'ICP', 'E105', 'Denisa Testová', 'A');
INSERT INTO Rezervace VALUES ('N105', '5408252938', 'ICP', 'N105', 'Michal Barta', 'N');
INSERT INTO Rezervace VALUES ('N105', '9009213939', 'IIPD', 'N105', 'Al Koholik', 'N');

INSERT INTO Jednorazova VALUES ('E105', '7652053937', 'ICP', TO_DATE('10.3.2015', 'DD.MM.YYYY'), '16:00');
INSERT INTO Jednorazova VALUES ('D105', '7404162931', 'IDS', TO_DATE('13.9.2013', 'DD.MM.YYYY'), '16:00');
INSERT INTO Jednorazova VALUES ('E105', '9009213939', 'IIPD', TO_DATE('10.3.1985', 'DD.MM.YYYY'), '17:00');

INSERT INTO Pravidelna VALUES ('E105', '9009213939', 'IIPD', 'Letni', 'L', TO_DATE('10.3.2015', 'DD.MM.YYYY'), '16:00');
INSERT INTO Pravidelna VALUES ('E105', '7652053937', 'ICP', 'Zimni', 'S', TO_DATE('10.12.2005', 'DD.MM.YYYY'), '20:00');
INSERT INTO Pravidelna VALUES ('D105', '7404162931', 'IDS', 'Zimni', 'O', TO_DATE('20.4.2010', 'DD.MM.YYYY'), '8:00');

--------------------------------------------------------------------------------
-- Select se 2 tabulkami, který vypíše vybavení uèebny D105

select Ucebna.Oznaceni, Vybaveni_Ucebny.Inventarni_Cislo, Vybaveni_Ucebny.Nazev_Polozky
FROM Ucebna, Vybaveni_Ucebny
where Ucebna.Oznaceni = Vybaveni_Ucebny.Mistnost and Ucebna.Oznaceni = 'D105';

--------------------------------------------------------------------------------
-- Select se 2 tabulkami, který vypíše všechny rezervace akademického pracovníka Al Koholíka

select Akademicky_Pracovnik.Jmeno, Akademicky_Pracovnik.Prijmeni, Akademicky_Pracovnik.Rodne_Cislo, Rezervace.Zkratka, Rezervace.Oznaceni_Ucebny, Rezervace.Jednorazova
FROM Rezervace, Akademicky_Pracovnik
where Rezervace.Rodne_Cislo = Akademicky_Pracovnik.Rodne_Cislo and Akademicky_Pracovnik.Jmeno = 'Al' and Akademicky_Pracovnik.Prijmeni = 'Koholik';

--------------------------------------------------------------------------------
-- Select se 3 tabulkami, který vypíše rezervace uèeben, které ve svém vybavení mají projektor

select Rezervace.*
FROM Rezervace, Ucebna, Vybaveni_Ucebny
where Rezervace.Oznaceni = Ucebna.Oznaceni and Ucebna.Oznaceni = Vybaveni_Ucebny.Mistnost and Vybaveni_Ucebny.Nazev_Polozky = 'Projektor';

--------------------------------------------------------------------------------
-- Select s agregaèní funkcí sum a klauzulí GROUP BY, který vypíše cenu vybavení jednotlivých uèeben

select Ucebna.Oznaceni, sum(Vybaveni_Ucebny.Porizovaci_Cena) Cena_Vybaveni_Ucebny
FROM Ucebna, Vybaveni_Ucebny
where Ucebna.Oznaceni = Vybaveni_Ucebny.Mistnost
group by Ucebna.Oznaceni;

--------------------------------------------------------------------------------
-- Select s agregaèní funkcí count a klauzulí GROUP BY, který vypíše poèet rezervací jednotlivých uèeben

select Ucebna.Oznaceni, count(*) Pocet_Rezervaci
FROM Ucebna, Rezervace
where Ucebna.Oznaceni = Rezervace.Oznaceni
group by Ucebna.Oznaceni;

--------------------------------------------------------------------------------
-- Select s predikátem EXISTS, který vypíše všechny akademické pracovníky, kteøí mají nìjakou rezervaci

select *
FROM Akademicky_Pracovnik
where exists( select *
              FROM Rezervace
              where Akademicky_Pracovnik.Rodne_Cislo = Rezervace.Rodne_Cislo);

--------------------------------------------------------------------------------
-- Select s predikátem IN, který vypíše všechno vybavení uèeben, které bylo poøízeno mezi zadanými datumy

select Vybaveni_Ucebny.*
from Vybaveni_Ucebny
where Vybaveni_Ucebny.Datum_Porizeni in (
    select Vybaveni_Ucebny.Datum_Porizeni
    from Vybaveni_Ucebny
    where Vybaveni_Ucebny.Datum_Porizeni between TO_DATE('8.6.2009', 'DD.MM.YY') and TO_DATE('15.12.2010', 'DD.MM.YY')
);