-- Created By  : Zatko Tomas (xzatko02)
-- Created Date: 13.10.2021
DROP TABLE Jizdenka_Zastavky;
DROP TABLE Symboly;
DROP TABLE Personal_Spoj;
DROP TABLE Vozidlo_Spoj;
DROP TABLE Spoj_Zastavka;
DROP TABLE Vozidlo;
DROP TABLE NavrhZastavky;
DROP TABLE Jizdenka;
DROP TABLE Zastavky;
DROP TABLE Spoj;
DROP TABLE Personal;
DROP TABLE Dopravca;
DROP TABLE Administrator;
DROP TABLE Cestujuci;

CREATE TABLE Cestujuci(
    id INT(11) NOT NULL AUTO_INCREMENT,
    meno VARCHAR(40) NOT NULL,
    priezvisko VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL,
    heslo VARCHAR(40) NOT NULL,
	PRIMARY KEY (id)
);
CREATE TABLE Administrator(
    id INT(11) NOT NULL AUTO_INCREMENT,
    meno VARCHAR(40) NOT NULL,
    priezvisko VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL,
    heslo VARCHAR(40) NOT NULL,
	PRIMARY KEY (id)
);
CREATE TABLE Dopravca(
    id INT(11) NOT NULL AUTO_INCREMENT,
    nazov VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL,
    heslo VARCHAR(40) NOT NULL,
	PRIMARY KEY (id)
);
CREATE TABLE Personal(
    id INT(11) NOT NULL AUTO_INCREMENT,
    meno VARCHAR(40) NOT NULL,
    priezvisko VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL,
    heslo VARCHAR(40) NOT NULL,
	PRIMARY KEY (id),
    id_dopravca_personal INTEGER,
    CONSTRAINT PK_id_dopravca_personal
		FOREIGN KEY (id_dopravca_personal) REFERENCES Dopravca (id)
		ON DELETE CASCADE
);
CREATE TABLE Spoj(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    cenova_kategoria VARCHAR(40),
    id_dopravca_spoje INTEGER,
    CONSTRAINT PK_id_dopravca_spoje
		FOREIGN KEY (id_dopravca_spoje) REFERENCES Dopravca (id)
		ON DELETE CASCADE
);
CREATE TABLE Zastavky(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    nazov_zastavky VARCHAR (40),
    geograficka_poloha VARCHAR(100)
);
CREATE TABLE Jizdenka(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    pocet_miest INTEGER,
    datum VARCHAR(20),
    id_spoj_jizdenky INTEGER,
    id_personal_jizdenka INTEGER,
    id_cestujuci_jizdenka INTEGER,
    CONSTRAINT PK_id_spoj_jizdenky
		FOREIGN KEY (id_spoj_jizdenky) REFERENCES Spoj (id)
		ON DELETE CASCADE,
    CONSTRAINT PK_id_personal_jizdenka
		FOREIGN KEY (id_personal_jizdenka) REFERENCES Personal (id)
		ON DELETE CASCADE,
    CONSTRAINT PK_id_cestujuci_jizdenka
		FOREIGN KEY (id_cestujuci_jizdenka) REFERENCES Cestujuci (id)
		ON DELETE CASCADE
);
CREATE TABLE NavrhZastavky(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    nazov VARCHAR(50),
    id_dopravca_navrhy INTEGER,
    id_administrator_potvrdenie INTEGER,
    stav VARCHAR(20),					-- potvrdena, nepotvrdena - default stav pri zvytvoreni, zamietnuta
    geograficka_poloha VARCHAR(100),
    CONSTRAINT PK_id_dopravca_navrhy	-- id dopravcu, ktory zastavku navrhuje
		FOREIGN KEY (id_dopravca_navrhy) REFERENCES Dopravca (id)
		ON DELETE CASCADE,
    CONSTRAINT PK_id_administrator_potvrdenie					-- kym bol navrh potvrdeny, adminove id
		FOREIGN KEY (id_administrator_potvrdenie) REFERENCES Administrator (id)
		ON DELETE CASCADE
);
CREATE TABLE Vozidlo(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    pocet_miest INTEGER,
    popis_vozidla VARCHAR(1500),
    aktualna_poloha VARCHAR(100),
    id_dopravca_vozidlo INTEGER,
    CONSTRAINT PK_id_dopravca_vozidlo
		FOREIGN KEY (id_dopravca_vozidlo) REFERENCES Dopravca (id)
		ON DELETE CASCADE
);

CREATE TABLE Spoj_Zastavka(
    id_spoju INTEGER,-- primarni klic
    id_zastavky INTEGER,
	cas_prejazdu VARCHAR(20),
    CONSTRAINT Spoj_Zastavka_PK
		PRIMARY KEY (id_spoju, id_zastavky),
	CONSTRAINT Spoj_Zastavka_id_spoju_FK
		FOREIGN KEY (id_spoju) REFERENCES Spoj (id)
		ON DELETE CASCADE,
	CONSTRAINT Spoj_Zastavka_id_zastavky_FK
		FOREIGN KEY (id_zastavky) REFERENCES Zastavky (id)
		ON DELETE CASCADE
);

CREATE TABLE Vozidlo_Spoj(
    id_vozidla INTEGER,-- primarni klic
    id_spoju INTEGER,
    CONSTRAINT Vozidlo_Spoj_PK
		PRIMARY KEY (id_vozidla, id_spoju),
	CONSTRAINT Vozidlo_Spoj_id_vozidla_FK
		FOREIGN KEY (id_vozidla) REFERENCES Vozidlo (id)
		ON DELETE CASCADE,
	CONSTRAINT Vozidlo_Spoj_id_spoju_FK
		FOREIGN KEY (id_spoju) REFERENCES Spoj (id)
		ON DELETE CASCADE
);

CREATE TABLE Personal_Spoj(
    id_personalu INTEGER,-- primarni klic
    id_spoju INTEGER,
    CONSTRAINT Personal_Spoj_PK
		PRIMARY KEY (id_personalu, id_spoju),
	CONSTRAINT Personal_Spoj_id_personalu_FK
		FOREIGN KEY (id_personalu) REFERENCES Personal (id)
		ON DELETE CASCADE,
	CONSTRAINT Personal_Spoj_id_spoju_FK
		FOREIGN KEY (id_spoju) REFERENCES Spoj (id)
		ON DELETE CASCADE
);

CREATE TABLE Symboly(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    symbol VARCHAR(500)
);

CREATE TABLE Jizdenka_Zastavky(
    id_jizdenka INTEGER,-- primarni klic
    id_zastavka INTEGER,
    CONSTRAINT Personal_Spoj_PK
		PRIMARY KEY (id_jizdenka, id_zastavka),
	CONSTRAINT Jizdenka_Zastavky_id_jizdenka_FK
		FOREIGN KEY (id_jizdenka) REFERENCES Jizdenka (id)
		ON DELETE CASCADE,
	CONSTRAINT Jizdenka_Zastavky_id_zastavka_FK
		FOREIGN KEY (id_zastavka) REFERENCES Zastavky (id)
		ON DELETE CASCADE
);

ALTER TABLE Personal AUTO_INCREMENT=20001;
ALTER TABLE Dopravca AUTO_INCREMENT=40001;
ALTER TABLE Administrator AUTO_INCREMENT=0;


INSERT INTO Symboly(symbol)
VALUES('??');

INSERT INTO Symboly(symbol)
VALUES('???');

INSERT INTO Symboly(symbol)
VALUES('Cestovn?? l??stok');

INSERT INTO Symboly(symbol)
VALUES('Pr??chod');

INSERT INTO Symboly(symbol)
VALUES('Po??et miest: ');

INSERT INTO Symboly(symbol)
VALUES('???');

INSERT INTO Symboly(symbol)
VALUES('???');

INSERT INTO Symboly(symbol)
VALUES('From: CP.poriadne.sk <cp.poriadne.sk@gmail.com>
To: {}{} <{}>
Subject: Registr??cia na webe CP.poriadne.sk

??spe??ne sme V??s zaregistrovali na port??li CP.poriadne.sk.
');

INSERT INTO Symboly(symbol)
VALUES('From: CP.poriadne.sk <cp.poriadne.sk@gmail.com>
To: {}{} <{}>
Subject: Upozornenie na podozriv?? aktivitu

Niekto sa pok????a prihl??si?? do V????ho ????tu na port??li CP.poriadne.sk. Ak ste to neboli Vy odpor????ame V??m si zmeni?? heslo.
');

INSERT INTO Symboly(symbol)
VALUES('From: CP.poriadne.sk <cp.poriadne.sk@gmail.com>
To: {}{} <{}>
Subject: Registr??cia na webe CP.poriadne.sk

Pr??ve ste boli zaregistrovan?? na port??li CP.poriadne.sk.
Va??e prihlasovacie ??daje s??
email: {}, heslo: {}.
');

INSERT INTO Symboly(symbol)
VALUES('From: CP.poriadne.sk <cp.poriadne.sk@gmail.com>
To: {}{} <{}>
Subject: CP cestovn?? l??stok

??akujeme za zak??penie cestovn??ho l??stka cez port??l CP.poriadne.sk.
V???? cestovn?? l??stok n??jdete na adrese {}.


');

INSERT INTO Symboly(symbol)
VALUES('From: CP.poriadne.sk <cp.poriadne.sk@gmail.com>
To: {}{} <{}>
Subject: CP obnova hesla

Na Va??u ??iados?? V??m bolo vygenerovan?? nov?? heslo pre pr??stup na str??nku CP.poriadne.sk. Odpor????ame V??m toto heslo ??o najsk??r zmeni??.

Va??e nov?? heslo: {}
');



INSERT INTO Administrator (meno, priezvisko, email, heslo)
VALUES ('Admin', 'Admin', 'admin@admin.com', 'password');

INSERT INTO Cestujuci (id, meno, priezvisko, email, heslo)		-- kvoli nakupu listov
VALUES (0, 'Admin', 'Admin', 'admin@admin.com', 'password');

INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Roman', 'Holota', 'romco22@gmail.com', 'R0m4nk0');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Sab??na', 'Machajd??kov??', 'sabina.machaj@gmail.com', 'jALfba156');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Ema', 'Madunick??', 'debilko@dement.dementor', 'pstrosS5');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Nikoleta', 'Znachorov??', 'nikoleta2000@zoznam.sk', 'nikA2000');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Petr', 'Ku??era', 'pet.kucera@seznam.cz', 'maoHaN59');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Martin', 'Rak??s', 'martin.rakus1@gmail.com', 'Matono12');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Tom????', 'Za??ko', 'tomas.zatko.ms@gmail.com', 'Password1');

INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Brno - ??AN Zvona??ka', '49.18544111694895, 16.61618288458226');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Hradec Kr??lov?? - Ter. HD', '50.21672012747056, 15.813392696254558');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Jihlava - aut.n??dr.', '49.399605746806806, 15.58112626924421');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Krom???????? - aut.n??dr.', '49.301279120575316, 17.40346965574991');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Liberec - aut.n??dr.', '50.7639690274061, 15.046831782783297');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Olomouc - hl.n??dr.', '49.58829230810149, 17.285827642269158');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Ostrava - ??AN', '49.83069560941868, 18.280434025077234');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Pardubice - hl.n??dr.', '50.034692610535, 15.75943068461215');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Plze?? - CAN', '49.74661449976352, 13.36276506925637');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Praha - Hlavn?? n??dra????', '50.08951055240178, 14.443010915305246');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Zl??n - aut.n??dr.', '49.22601902662707, 17.659865640401723');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('??esk?? Krumlov', '48.8117388898195, 14.322524098060063');


INSERT INTO Dopravca (nazov, email, heslo)
VALUES ('RegioJet', 'regiojet@regiojet.com', 'studentAgency2011ToTheInfinityAndBeyond'); -- dopravca c.400001
INSERT INTO Dopravca (nazov, email, heslo)
VALUES ('LeoExpress', 'expressileo@leoexpress.com', 'Kah9-Cy.a55'); -- dopravca c.400002
INSERT INTO Dopravca (nazov, email, heslo)
VALUES ('FlixBUS', 'flixmotors@flixbus.com', 'flexiBuZzes4596'); -- dopravca c.400003

INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Patrik', 'Jacola', 'patrikus@jacolus.sk', '2BitStudent', '40001'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Veronika', 'Markov??', 'markovav@gmail.com', 'novakovaV7891', '40001'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Eleon??ra', 'Tr??falov??', 'elitra@gmail.com', 'Mauricius2004', '40001'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Jakub??', 'Davini??', 'davinjacob@seznam.cz', 'petrone14H', '40001'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Robert', '??tekl????', 'stekliR@gmail.com', 'monsterMan10', '40002'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Nat??lia', 'Chud??kov??', 'naty4997@seznam.cz', 'Kasyka54', '40002'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Nikola', '??vecov??', 'nikita1997@seznam.cz', '9nicashA9', '40002'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Vanda', '??lot????ov??', 'zlotir.vanda95@seznam.cz', 'aJzvsm04', '40002'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Vanesa', 'Slunsk??', 'slunskavanesa1@seznam.cz', 'van95Sluun', '40003'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Tereza', 'He??kov??', 'hecka.ter@seznam.cz', 'teHec6x', '40003'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Mark??ta', 'Biernatov??', 'biernatovam@seznam.cz', 'markBier2001', '40003'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Mia', 'Bo??eck??', 'mia.borecka@seznam.cz', 'boreckaM2001', '40003'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Martin', 'Sulo', 'marto.s12@seznam.cz', 'Martinos45ds', '40003'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Petr', 'Marec', 'petr.marec@seznam.cz', 'Petr2000KL', '40003'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Jakub', 'Bajlo', 'jacob.baj@seznam.cz', 'JakubB4ja5', '40003'); -- id_dopravca_personal (3: FLIXBUS)

-- REGIOJET cisla vozidiel: 1-4
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('61', 'Luxusn?? ??lut?? autobusy. Vozov?? park v korpor??tn?? ??lut?? barv?? tvo???? ??pan??lsk?? autobusy Irizar na podvozc??ch Scania nebo Volvo s luxusn?? v??bavou Fun&Relax. Vozov?? park ka??doro??n?? obm????ujeme o dal???? nov?? autobusy ve stylu Fun&Relax. V ??ervnu 2020 jsme p??iv??tali v na???? ??lut?? flotile dal????ch 10 zbrusu nov??ch voz?? nejnov??j???? modelov?? ??ady Irizar i8. Autobusy jsou 61m??stn?? s pohodln??mi celoko??en??mi seda??kami a monitory SDHD s vysok??m rozli??en??m. Ka??d?? sedadlo m?? tak?? nov?? nainstalovanou svou vlastn?? z??suvku. Bezpe??nostn?? standardy pos??lilo nejmodern??j???? ??pi??kov?? samohas??c?? za????zen?? motorov??ho prostoru. Nov?? vozy nav????ily po??et autobus?? Irizar i8 a?? na 55 voz??. Cestuj??c?? ??ek?? luxusn?? a modern?? design, kter?? na prvn?? pohled zaujme v??razn??j????mi a ost??ej????mi liniemi. Interi??r p??in?????? nadstandardn?? pohodl??. Komforn?? sedadla jsou pln?? nastaviteln?? a v ka??d??m z nich je zabudovan?? obrazovka s multimedi??ln??m z??bavn??m syst??mem, v n??m?? jsou dostupn?? filmy, seri??ly nebo online hry. V autobusech je bezplatn?? dostupn?? tak?? p??ipojen?? k internetu. Samoz??ejmost?? je v??konn?? klimatiza??n?? syst??m, LED osv??tlen?? a toaleta. Komfort a bezpe??nost na??ich autobus?? je pro n??s prioritou, proto pravideln?? investujeme do obnovy vozov??ho parku. Novou generaci voz?? Irizar i8 na podvozc??ch Volvo nebo Scania jsme nasadili do provozu jako prvn?? autobusov?? dopravci ve st??edn?? Evrop??. Autobusy Fun&Relax nab??z??me i k pron??jmu pro skupinov?? z??jezdy nebo k prodeji.', 'Brno - ??AN Zvona??ka', 40001);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('59', 'Luxusn?? ??lut?? autobusy. Vozov?? park v korpor??tn?? ??lut?? barv?? tvo???? ??pan??lsk?? autobusy Irizar na podvozc??ch Scania nebo Volvo s luxusn?? v??bavou Fun&Relax. Vozov?? park ka??doro??n?? obm????ujeme o dal???? nov?? autobusy ve stylu Fun&Relax. V ??ervnu 2020 jsme p??iv??tali v na???? ??lut?? flotile dal????ch 10 zbrusu nov??ch voz?? nejnov??j???? modelov?? ??ady Irizar i8. Autobusy jsou 61m??stn?? s pohodln??mi celoko??en??mi seda??kami a monitory SDHD s vysok??m rozli??en??m. Ka??d?? sedadlo m?? tak?? nov?? nainstalovanou svou vlastn?? z??suvku. Bezpe??nostn?? standardy pos??lilo nejmodern??j???? ??pi??kov?? samohas??c?? za????zen?? motorov??ho prostoru. Nov?? vozy nav????ily po??et autobus?? Irizar i8 a?? na 55 voz??. Cestuj??c?? ??ek?? luxusn?? a modern?? design, kter?? na prvn?? pohled zaujme v??razn??j????mi a ost??ej????mi liniemi. Interi??r p??in?????? nadstandardn?? pohodl??. Komforn?? sedadla jsou pln?? nastaviteln?? a v ka??d??m z nich je zabudovan?? obrazovka s multimedi??ln??m z??bavn??m syst??mem, v n??m?? jsou dostupn?? filmy, seri??ly nebo online hry. V autobusech je bezplatn?? dostupn?? tak?? p??ipojen?? k internetu. Samoz??ejmost?? je v??konn?? klimatiza??n?? syst??m, LED osv??tlen?? a toaleta. Komfort a bezpe??nost na??ich autobus?? je pro n??s prioritou, proto pravideln?? investujeme do obnovy vozov??ho parku. Novou generaci voz?? Irizar i8 na podvozc??ch Volvo nebo Scania jsme nasadili do provozu jako prvn?? autobusov?? dopravci ve st??edn?? Evrop??. Autobusy Fun&Relax nab??z??me i k pron??jmu pro skupinov?? z??jezdy nebo k prodeji.', 'Brno - ??AN Zvona??ka', 40001);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('47', 'Luxusn?? ??lut?? autobusy. Vozov?? park v korpor??tn?? ??lut?? barv?? tvo???? ??pan??lsk?? autobusy Irizar na podvozc??ch Scania nebo Volvo s luxusn?? v??bavou Fun&Relax. Vozov?? park ka??doro??n?? obm????ujeme o dal???? nov?? autobusy ve stylu Fun&Relax. V ??ervnu 2020 jsme p??iv??tali v na???? ??lut?? flotile dal????ch 10 zbrusu nov??ch voz?? nejnov??j???? modelov?? ??ady Irizar i8. Autobusy jsou 61m??stn?? s pohodln??mi celoko??en??mi seda??kami a monitory SDHD s vysok??m rozli??en??m. Ka??d?? sedadlo m?? tak?? nov?? nainstalovanou svou vlastn?? z??suvku. Bezpe??nostn?? standardy pos??lilo nejmodern??j???? ??pi??kov?? samohas??c?? za????zen?? motorov??ho prostoru. Nov?? vozy nav????ily po??et autobus?? Irizar i8 a?? na 55 voz??. Cestuj??c?? ??ek?? luxusn?? a modern?? design, kter?? na prvn?? pohled zaujme v??razn??j????mi a ost??ej????mi liniemi. Interi??r p??in?????? nadstandardn?? pohodl??. Komforn?? sedadla jsou pln?? nastaviteln?? a v ka??d??m z nich je zabudovan?? obrazovka s multimedi??ln??m z??bavn??m syst??mem, v n??m?? jsou dostupn?? filmy, seri??ly nebo online hry. V autobusech je bezplatn?? dostupn?? tak?? p??ipojen?? k internetu. Samoz??ejmost?? je v??konn?? klimatiza??n?? syst??m, LED osv??tlen?? a toaleta. Komfort a bezpe??nost na??ich autobus?? je pro n??s prioritou, proto pravideln?? investujeme do obnovy vozov??ho parku. Novou generaci voz?? Irizar i8 na podvozc??ch Volvo nebo Scania jsme nasadili do provozu jako prvn?? autobusov?? dopravci ve st??edn?? Evrop??. Autobusy Fun&Relax nab??z??me i k pron??jmu pro skupinov?? z??jezdy nebo k prodeji.', 'Brno - ??AN Zvona??ka', 40001);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('55', 'Luxusn?? ??lut?? autobusy. Vozov?? park v korpor??tn?? ??lut?? barv?? tvo???? ??pan??lsk?? autobusy Irizar na podvozc??ch Scania nebo Volvo s luxusn?? v??bavou Fun&Relax. Vozov?? park ka??doro??n?? obm????ujeme o dal???? nov?? autobusy ve stylu Fun&Relax. V ??ervnu 2020 jsme p??iv??tali v na???? ??lut?? flotile dal????ch 10 zbrusu nov??ch voz?? nejnov??j???? modelov?? ??ady Irizar i8. Autobusy jsou 61m??stn?? s pohodln??mi celoko??en??mi seda??kami a monitory SDHD s vysok??m rozli??en??m. Ka??d?? sedadlo m?? tak?? nov?? nainstalovanou svou vlastn?? z??suvku. Bezpe??nostn?? standardy pos??lilo nejmodern??j???? ??pi??kov?? samohas??c?? za????zen?? motorov??ho prostoru. Nov?? vozy nav????ily po??et autobus?? Irizar i8 a?? na 55 voz??. Cestuj??c?? ??ek?? luxusn?? a modern?? design, kter?? na prvn?? pohled zaujme v??razn??j????mi a ost??ej????mi liniemi. Interi??r p??in?????? nadstandardn?? pohodl??. Komforn?? sedadla jsou pln?? nastaviteln?? a v ka??d??m z nich je zabudovan?? obrazovka s multimedi??ln??m z??bavn??m syst??mem, v n??m?? jsou dostupn?? filmy, seri??ly nebo online hry. V autobusech je bezplatn?? dostupn?? tak?? p??ipojen?? k internetu. Samoz??ejmost?? je v??konn?? klimatiza??n?? syst??m, LED osv??tlen?? a toaleta. Komfort a bezpe??nost na??ich autobus?? je pro n??s prioritou, proto pravideln?? investujeme do obnovy vozov??ho parku. Novou generaci voz?? Irizar i8 na podvozc??ch Volvo nebo Scania jsme nasadili do provozu jako prvn?? autobusov?? dopravci ve st??edn?? Evrop??. Autobusy Fun&Relax nab??z??me i k pron??jmu pro skupinov?? z??jezdy nebo k prodeji.', 'Brno - ??AN Zvona??ka', 40001);

-- LEO EXPRESS cisla vozidiel: 5
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('51', 'Business Class v autobusoch: Potrebujete v pokoji pracova?? a chcete si u??i?? vybran?? ob??erstvenie zadarmo? Doprajte si nad??tandardn?? komfort i v priebehu cesty autobusom. Slu??by navy??e v Business Class: Kr????ovsk?? priestor pre nohy. Bal????ek s ob??erstven??m v cene l??stka (bal????ek obsahuje ??al???? nealkoholick?? n??poj, sladk?? a slan?? snack). Na vybran??ch spojoch navy??e. Luxusn?? ko??en?? sedadl?? s dodato??nou opierkou hlavy. Stol??ky prisp??soben?? na pr??cu s notebookom. Stevard s prednostnou obsluhou.', 'Olomouc - hl.n??dr.', 40002);

-- FLIX BUS cisla vozidiel: 6-14
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('54', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Liberec - aut.n??dr.', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('50', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Liberec - aut.n??dr.', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('56', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Jihlava - aut.n??dr.', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Praha - Hlavn?? n??dra????', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Brno - ??AN Zvona??ka', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Brno - ??AN Zvona??ka', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Brno - ??AN Zvona??ka', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Brno - ??AN Zvona??ka', 40003);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Na??e slu??by v autobuse s FlixBusom Pri ceste FlixBusom m??te zaru??en?? najlep??ie slu??by. Vo v??etk??ch na??ich autobusoch n??jdete bezplatn?? Wi-fi, extra priestor na nohy, ob??erstvenie a n??poje za n??zke ceny, mnoho z??suviek a dostatok priestoru na bato??inu. V??aka bezplatnej Wi-fi v na??ich autobusoch sa vyhnete nude ??? m????ete str??vi?? cestu surfovan??m po internete, online pokecom s priate??mi a prezeran??m emailov, to v??etko so 4G r??chlos??ou! FlixBus v??m garantuje tie?? sedadlo s extra priestorom na nohy. Na??e modern?? autobusy s?? vybaven?? pohodln??mi sedadlami a mno??stvom priestoru. V??etky sedadl?? maj?? nastavite??n?? operadl?? a s?? pohodln?? aj na dlh????ch cest??ch. Vo Flixbuse sa o v??s v??dy dobre postar??me: na palube niektor??ch autobusov si m????ete k??pi?? ob??erstvenie a n??poje za n??zke ceny. Chcete surfova?? po internete, pokeca?? si online s priate??mi alebo pracova?? na notebooku, ale bat??ria je vybit??? ??iadny probl??m! H??adajte symbol z??suvky alebo sa op??tajte na??ich priate??sk??ch ??of??rov, kde n??jdete jednu z mnoh??ch z??suviek v autobusoch FlixBus. E??te bude chv????u trva??, k??m sa dostanete na svoju z??stavku? ??iadny d??vod na nervozitu! Vo v??etk??ch autobusoch FlixBus je toaleta. Na??e FlixBus autobusy maj?? dostatok priestoru na bato??inu. Ulo??te si pr??ru??n?? bato??inu do priehradiek nad hlavou a priate??sk?? ??of??ri v??m pom????u nalo??i?? norm??lnu bato??inu. ', 'Brno - ??AN Zvona??ka', 40003);


-- BRNO -> PRAHA, REGIOJET (id 1)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40001');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('1', '1', '12:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('1', '10', '14:30'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('1', '1'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40001');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('2', '1', '9:30'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('2', '10', '12:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('2', '2'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40001');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('3', '1', '14:50'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('3', '10', '17:30'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('3', '3'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40001');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('4', '1', '18:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('4', '10', '20:30'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('4', '4'); -- regio, Brno-Praha

-- OLOMOUC -> OSTRAVA, LEO EXPRESS (id 2)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('5', '6', '9:20'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('5', '7', '10:30'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '5'); -- leo express, Olomouc-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('6', '6', '12:10'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('6', '7', '13:20'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '6'); -- leo express, Olomouc-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('7', '6', '15:45'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('7', '7', '16:55'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '7'); -- leo express, Olomouc-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('8', '6', '18:50'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('8', '7', '20:00'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '8'); -- leo express, Olomouc-Ostrava

-- OSTRAVA -> OLOMOUC, LEO EXPRESS (id 2)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('9', '7', '10:40'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('9', '6', '11:50'); -- Olomouc
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '9'); -- leo express, Ostrava-Olomouc

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('10', '7', '13:30'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('10', '6', '14:40'); -- Olomouc
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '10'); -- leo express, Ostrava-Olomouc

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40002');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('11', '7', '17:20'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('11', '6', '18:30'); -- Olomouc
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '11'); -- leo express, Ostrava-Olomouc

-- LIBEREC -> HRADEC KRALOVE -> PARDUBICE, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '5', '9:30'); -- Liberec
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '2', '11:25'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '8', '12:24'); -- Pardubice
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '12'); -- flix bus, Liberec-Hradec Kralove-

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('13', '5', '13:30'); -- Liberec
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('13', '2', '15:30'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('13', '8', '16:29'); -- Pardubice
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '13'); -- flix bus, Liberec-Hradec Kralove-Pardubice

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('14', '5', '17:30'); -- Liberec
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('14', '2', '19:30'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('14', '8', '20:19'); -- Pardubice
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '14'); -- flix bus, Liberec-Hradec Kralove-Pardubice

-- PARDUBICE -> HRADEC KRALOVE -> LIBEREC, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('15', '8', '13:40'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('15', '2', '14:20'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('15', '5', '16:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '15'); -- flix bus, Liberec-Hradec Kralove-Pardubice

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '8', '6:42'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '2', '7:35'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '5', '9:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '16'); -- flix bus, Pardubice-Hradec Kralove-Liberec

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '8', '17:35'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '2', '18:35'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '5', '20:25'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '17'); -- flix bus, Pardubice-Hradec Kralove-Liberec

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('18', '8', '9:21'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('18', '2', '10:25'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('18', '5', '12:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '18'); -- flix bus, Pardubice-Hradec Kralove-Liberec

-- JIHLAVA -> KROMERIZ, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '3', '7:40'); -- Jihlava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '4', '11:17'); -- Kromeriz
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('8', '19'); -- flix bus, Jihlava-Kromeriz

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('20', '3', '15:30'); -- Jihlava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('20', '4', '18:16'); -- Kromeriz
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('8', '20'); -- flix bus, Jihlava-Kromeriz

-- KROMERIZ -> JIHLAVA, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('21', '4', '12:10'); -- Kromeriz
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('21', '3', '15:20'); -- Jihlava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('8', '21'); -- flix bus, Kromeriz-Jihlava

-- PRAHA -> PLZEN, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('22', '10', '8:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('22', '9', '9:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '22'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('23', '10', '10:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('23', '9', '11:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '23'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('24', '10', '12:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('24', '9', '13:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '24'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('25', '10', '14:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('25', '9', '15:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '25'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('26', '10', '16:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('26', '9', '17:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '26'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('27', '10', '18:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('27', '9', '19:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '27'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('28', '10', '20:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('28', '9', '21:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '28'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('29', '10', '22:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('29', '9', '23:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '29'); -- flix bus, Praha-Plzen

-- PLZEN -> PRAHA, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('30', '9', '7:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('30', '10', '8:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '30'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('31', '9', '9:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('31', '10', '10:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '31'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('32', '9', '11:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('32', '10', '12:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '32'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('33', '9', '13:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('33', '10', '14:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '33'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('34', '9', '15:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('34', '10', '16:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '34'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('35', '9', '17:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('35', '10', '18:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '35'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('36', '9', '19:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('36', '10', '20:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '36'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('37', '9', '21:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('37', '10', '22:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '37'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('38', '9', '23:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('38', '10', '23:59'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '38'); -- flix bus, Plzen-Praha

-- BRNO -> ZLIN -> OSTRAVA, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('39', '1', '9:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('39', '11', '10:45'); -- Zlin
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('39', '7', '14:10'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('10', '39'); -- flix bus, Brno-Zlin-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('40', '1', '15:15'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('40', '11', '17:35'); -- Zlin
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('40', '7', '20:57'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('11', '40'); -- flix bus, Brno-Zlin-Ostrava

-- OSTRAVA -> ZLIN -> BRNO, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('41', '7', '14:15'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('41', '11', '17:45'); -- Zlin
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('41', '1', '20:00'); -- Brno
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('10', '41'); -- flix bus, Ostrava-Zlin-Brno

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('40003');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('42', '7', '9:40'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('42', '11', '12:45'); -- Zlin
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('42', '1', '14:05'); -- Brno
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('11', '42'); -- flix bus, Ostrava-Zlin-Brno


# PRIDELENIE PERSONALU K SPOJOM
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20001', '1');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20002', '2');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20003', '3');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20004', '4');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '5');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '6');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '7');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '8');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '9');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '10');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20005', '11');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20006', '12');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20007', '13');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20006', '14');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20006', '15');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20006', '16');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20007', '17');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20007', '18');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20008', '19');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20008', '20');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20008', '21');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '22');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '23');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '24');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '25');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '26');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '27');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '28');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '29');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '30');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '31');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '32');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '33');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '34');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '35');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '36');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '37');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20009', '38');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20010', '39');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20011', '40');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20010', '41');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('20011', '42');




