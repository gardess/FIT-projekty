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

-- 3. Èást
/*
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

--------------------------------------------------------------------------------
*/
-- 4. Èást
--------------------------------------------------------------------------------
--  Trigger pro kontrolu rodného èísla
CREATE OR REPLACE TRIGGER tr_rodc
  BEFORE INSERT OR UPDATE OF Rodne_Cislo ON Akademicky_Pracovnik
  FOR EACH ROW
DECLARE
  rod_c Akademicky_Pracovnik.Rodne_Cislo%TYPE;
  den NUMBER(2);
  mesic NUMBER(2);
  rok NUMBER(2);
BEGIN
  rod_c := :NEW.rodne_cislo;             -- z rodneho cisla ...
  mesic := MOD( (rod_c / 1000000), 100); -- zjistime mesic
  den   := MOD( (rod_c / 10000), 100);   -- den
  rok   := rod_c / 100000000;            -- rok

  IF ( MOD(rod_c, 11) <> 0 ) THEN
    Raise_Application_Error (-20203, 'Neplatne rodne cislo: Neni delitelne 11');
  END IF;

  -- jestli je cislo vetsi nez 50, pak se jedna o zenu a 50 odecteme
  IF ( mesic > 50 ) THEN
    mesic := mesic - 50;
  END IF;
  -- kontrola toho, zda mesic je v rozsahu 1-12
  IF ( mesic > 12 ) OR ( mesic = 0) THEN
    Raise_Application_Error (-20204, 'Neplatny mesic');
  END IF;
  -- kontrola toho, zda den je v rozsahu 1-31
  IF ( den > 31 ) OR ( den = 0) THEN
    Raise_Application_Error (-20205, 'Neplatny den');
  END IF;
  -- pokud se nejedna o platne datum, pak vznikne vyjimka

END tr_rodc;
/
/*-- Pro pøedvedení funkènosti
select * from Akademicky_Pracovnik;
INSERT INTO Akademicky_Pracovnik VALUES ('9256276733', 'Lukáš', 'Balík', 'Bc.', TO_DATE('16.07.1984', 'DD.MM.YY'), 'Muz', 'Kotlarska 19, Brno', 'Pocitacove systemy'); -- Spravne rodne cislo
INSERT INTO Akademicky_Pracovnik VALUES ('9256276732', 'Matìj', 'Janota', 'Bc.', TO_DATE('31.01.1966', 'DD.MM.YY'), 'Muz', 'Revolucni 25, Brno', 'Inteligentni systemy'); -- Spatne rodne cislo
select * from Akademicky_Pracovnik;
*/

--------------------------------------------------------------------------------
--  Trigger pro automatické generování hodnot primárního klíèe nìjaké tabulky ze sekvence
CREATE OR REPLACE TRIGGER tr_PK 
BEFORE INSERT ON Vybaveni_Ucebny 
FOR EACH ROW
WHEN (new.Inventarni_Cislo IS NULL)
BEGIN
  :new.Inventarni_Cislo := Citac_Vybaveni.NEXTVAL;
END;
/
/*-- Pro pøedvedení funkènosti
select * from Vybaveni_Ucebny;
INSERT INTO Vybaveni_Ucebny (Nazev_Polozky, Urceni, Porizovaci_Cena, Datum_Porizeni, Mistnost) VALUES ('Projektor', 'K promitani', '2,00', TO_DATE('15.12.2010', 'DD.MM.YY'), 'D105'); -- Inventarni cislo neni zadano
INSERT INTO Vybaveni_Ucebny (Inventarni_Cislo, Nazev_Polozky, Urceni, Porizovaci_Cena, Datum_Porizeni, Mistnost) VALUES ('150', 'Projektor', 'K promitani', '1,00', TO_DATE('15.12.2010', 'DD.MM.YY'), 'D105'); -- Invertarni cislo je zadano
select * from Vybaveni_Ucebny;
*/

--------------------------------------------------------------------------------
--  Procedura pro mazani rezervaci pomoci rodneho cisla akademickeho pracovnika 
CREATE OR REPLACE PROCEDURE ZRUSIT_REZERVACE (Rodne_Cislo NUMBER)
IS
  cursor pred is select * from Rezervace where Rezervace.Rodne_Cislo = ZRUSIT_REZERVACE.Rodne_Cislo;
  radek pred%ROWTYPE;
begin
  open pred;
  loop
    fetch pred into radek;
    exit when pred%NOTFOUND;
    DELETE FROM Rezervace WHERE (Rezervace.Rodne_Cislo = ZRUSIT_REZERVACE.Rodne_Cislo);
    DELETE FROM Jednorazova WHERE (Jednorazova.Rodne_Cislo = ZRUSIT_REZERVACE.Rodne_Cislo);
    DELETE FROM Pravidelna WHERE (Pravidelna.Rodne_Cislo = ZRUSIT_REZERVACE.Rodne_Cislo);
  end loop;
end ZRUSIT_REZERVACE;
/

/* -- Pro pøedvedení funkènosti
select * from Rezervace;
select * from Jednorazova;
select * from Pravidelna;
exec ZRUSIT_REZERVACE('9009213939');
select * from Rezervace;
select * from Jednorazova;
select * from Pravidelna;
*/

--------------------------------------------------------------------------------
--  Procedura pro mazani ucebny pomoci oznaceni ucebny
CREATE OR REPLACE PROCEDURE ODSTRANIT_UCEBNU (Oznaceni VARCHAR)
IS
BEGIN
  DELETE FROM Vybaveni_Ucebny WHERE (Vybaveni_Ucebny.Mistnost = ODSTRANIT_UCEBNU.Oznaceni);
  DELETE FROM Rezervace WHERE (Rezervace.Oznaceni = ODSTRANIT_UCEBNU.Oznaceni);
  DELETE FROM Ucebna WHERE (Ucebna.Oznaceni = ODSTRANIT_UCEBNU.Oznaceni);
END ODSTRANIT_UCEBNU;
/
/*-- Pro pøedvedení funkènosti
select * from ucebna;
EXEC ODSTRANIT_UCEBNU('D105');
select * from ucebna;
*/

--------------------------------------------------------------------------------
--  Procedura pro vypsani rezervaci akademickeho pracovnika dle jeho rodneho cisla
CREATE OR REPLACE PROCEDURE VYPSAT_REZERVACE (Rodne_Cislo NUMBER)
IS
  cursor pred is select * from Rezervace where Rezervace.Rodne_Cislo = VYPSAT_REZERVACE.Rodne_Cislo;
  radek pred%ROWTYPE;
begin
  open pred;
  loop
    fetch pred into radek;
    exit when pred%NOTFOUND;
      dbms_output.put_line(radek.Oznaceni || ' ' || radek.Zkratka || ' ' || radek.Jednorazova);
  end loop;
end VYPSAT_REZERVACE;
/
/*-- Pro pøedvedení funkènosti
exec VYPSAT_REZERVACE('7710110012');
*/

--------------------------------------------------------------------------------
--  Pouziti indexu a EXPLAIN PLAN
-- EXPLAIN PLAN bez indexu
EXPLAIN PLAN FOR 
  SELECT Ucebna.Oznaceni, sum(Vybaveni_Ucebny.Porizovaci_Cena) Cena_Vybaveni_Ucebny
  FROM Ucebna, Vybaveni_Ucebny
  where Ucebna.Oznaceni = Vybaveni_Ucebny.Mistnost
  group by Ucebna.Oznaceni; 

SELECT plan_table_output
  from table(dbms_xplan.display());

create index vybav on Vybaveni_Ucebny(Mistnost); -- Vytvoreni indexu

-- EXPLAIN PLAN s indexem
EXPLAIN PLAN FOR 
  SELECT Ucebna.Oznaceni, sum(Vybaveni_Ucebny.Porizovaci_Cena) Cena_Vybaveni_Ucebny
  FROM Ucebna, Vybaveni_Ucebny
  where Ucebna.Oznaceni = Vybaveni_Ucebny.Mistnost
  group by Ucebna.Oznaceni; 

SELECT plan_table_output
  from table(dbms_xplan.display());
  
/* -- Select pro testování  
select Ucebna.Oznaceni, sum(Vybaveni_Ucebny.Porizovaci_Cena) Cena_Vybaveni_Ucebny
FROM Ucebna, Vybaveni_Ucebny
where Ucebna.Oznaceni = Vybaveni_Ucebny.Mistnost
group by Ucebna.Oznaceni;*/

--------------------------------------------------------------------------------
--  Pøiøazení práv
/*
GRANT ALL ON Akademicky_Pracovnik TO rychly;
GRANT ALL ON Predmet TO rychly;
GRANT ALL ON AP_Predmet TO rychly;
GRANT ALL ON Ucebna TO rychly;
GRANT ALL ON Rezervace TO rychly;
GRANT ALL ON Vybaveni_Ucebny TO rychly;
GRANT ALL ON Jednorazova TO rychly;
GRANT ALL ON Pravidelna TO rychly;

GRANT ALL ON Akademicky_Pracovnik TO bartik;
GRANT ALL ON Predmet TO bartik;
GRANT ALL ON AP_Predmet TO bartik;
GRANT ALL ON Ucebna TO bartik;
GRANT ALL ON Rezervace TO bartik;
GRANT ALL ON Vybaveni_Ucebny TO bartik;
GRANT ALL ON Jednorazova TO bartik;
GRANT ALL ON Pravidelna TO bartik;*/

--------------------------------------------------------------------------------
--  Materializovaný pohled
create materialized view log on Akademicky_Pracovnik with rowid;
create materialized view log on Rezervace with rowid;

drop MATERIALIZED view AP_Rezervace;
create materialized view AP_Rezervace
  nologging
  cache
  build immediate
  refresh fast on commit
  enable query rewrite
  as
    select Akademicky_Pracovnik.Jmeno, Akademicky_Pracovnik.Prijmeni, Rezervace.Oznaceni, Akademicky_Pracovnik.rowid as AP_rowid, Rezervace.rowid as R_rowid
    from Akademicky_Pracovnik, Rezervace
    where Akademicky_Pracovnik.Rodne_Cislo = Rezervace.Rodne_Cislo;

--select * from AP_Rezervace; -- zobrazeni pohledu

/* -- Materializovaný pohled spouští druhý èlen týmu
create materialized view log on xgarda04.Akademicky_Pracovnik with rowid;
create materialized view log on xgarda04.Rezervace with rowid;
create materialized view AP_Rezervace
  nologging
  cache
  build immediate
  refresh fast on commit
  enable query rewrite
  as
    select xgarda04.Akademicky_Pracovnik.Jmeno, xgarda04.Akademicky_Pracovnik.Prijmeni, xgarda04.Rezervace.Oznaceni, xgarda04.Akademicky_Pracovnik.rowid as AP_rowid, xgarda04.Rezervace.rowid as R_rowid
    from xgarda04.Akademicky_Pracovnik, xgarda04.Rezervace
    where xgarda04.Akademicky_Pracovnik.Rodne_Cislo = xgarda04.Rezervace.Rodne_Cislo;

GRANT ALL ON AP_Rezervace to xgarda04;
*/

COMMIT;