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
		ON DELETE CASCADE,
	stav VARCHAR(20),			-- zaplatena, nezaplatena
	potvrdenie VARCHAR (20)		-- potvrdena, nepotvrdena
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
    symbol VARCHAR(20)
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

INSERT INTO Symboly(symbol)
VALUES('š');

INSERT INTO Symboly(symbol)
VALUES('€');

INSERT INTO Symboly(symbol)
VALUES('Cestovný lístok');

INSERT INTO Symboly(symbol)
VALUES('Príchod');

INSERT INTO Symboly(symbol)
VALUES('Počet miest: ');

INSERT INTO Symboly(symbol)
VALUES('↔');

INSERT INTO Symboly(symbol)
VALUES('→');

INSERT INTO Administrator (meno, priezvisko, email, heslo)
VALUES ('Admin', 'Admin', 'admin@admin.com', 'password');

INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Roman', 'Holota', 'romco22@gmail.com', 'R0m4nk0');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Sabína', 'Machajdíková', 'sabina.machaj@gmail.com', 'jALfba156');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Ema', 'Madunická', 'debilko@dement.dementor', 'pstrosS5');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Nikoleta', 'Znachorová', 'nikoleta2000@zoznam.sk', 'nikA2000');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Petr', 'Kučera', 'pet.kucera@seznam.cz', 'maoHaN59');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Martin', 'Rakús', 'martin.rakus1@gmail.com', 'Matono12');
INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Tomáš', 'Zaťko', 'tomas.zatko.ms@gmail.com', 'Password1');

INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Brno - ÚAN Zvonařka', '49.18544111694895, 16.61618288458226');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Hradec Králové - Ter. HD', '50.21672012747056, 15.813392696254558');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Jihlava - aut.nádr.', '49.399605746806806, 15.58112626924421');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Kroměříž - aut.nádr.', '49.301279120575316, 17.40346965574991');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Liberec - aut.nádr.', '50.7639690274061, 15.046831782783297');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Olomouc - hl.nádr.', '49.58829230810149, 17.285827642269158');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Ostrava - ÚAN', '49.83069560941868, 18.280434025077234');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Pardubice - hl.nádr.', '50.034692610535, 15.75943068461215');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Plzeň - CAN', '49.74661449976352, 13.36276506925637');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Praha - Hlavní nádraží', '50.08951055240178, 14.443010915305246');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Zlín - aut.nádr.', '49.22601902662707, 17.659865640401723');
INSERT INTO Zastavky (nazov_zastavky, geograficka_poloha)
VALUES ('Český Krumlov', '48.8117388898195, 14.322524098060063');


INSERT INTO Dopravca (nazov, email, heslo)
VALUES ('RegioJet', 'regiojet@regiojet.com', 'studentAgency2011ToTheInfinityAndBeyond'); -- dopravca c.1
INSERT INTO Dopravca (nazov, email, heslo)
VALUES ('LeoExpress', 'expressileo@leoexpress.com', 'Kah9-Cy.a55'); -- dopravca c.2
INSERT INTO Dopravca (nazov, email, heslo)
VALUES ('FlixBUS', 'flixmotors@flixbus.com', 'flexiBuZzes4596'); -- dopravca c.3

INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Patrik', 'Jacola', 'patrikus@jacolus.sk', '2BitStudent', '1'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Veronika', 'Marková', 'markovav@gmail.com', 'novakovaV7891', '1'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Eleonóra', 'Trúfalová', 'elitra@gmail.com', 'Mauricius2004', '1'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Jakubť', 'Davinič', 'davinjacob@seznam.cz', 'petrone14H', '1'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Robert', 'Štekláč', 'stekliR@gmail.com', 'monsterMan10', '2'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Natália', 'Chudíková', 'naty4997@seznam.cz', 'Kasyka54', '2'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Nikola', 'Švecová', 'nikita1997@seznam.cz', '9nicashA9', '2'); -- id_dopravca_personal (2: LEOEXPRESS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Vanda', 'Žlotířová', 'zlotir.vanda95@seznam.cz', 'aJzvsm04', '2'); -- id_dopravca_personal (1: REGIOJET)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Vanesa', 'Slunská', 'slunskavanesa1@seznam.cz', 'van95Sluun', '3'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Tereza', 'Hečková', 'hecka.ter@seznam.cz', 'teHec6x', '3'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Markéta', 'Biernatová', 'biernatovam@seznam.cz', 'markBier2001', '3'); -- id_dopravca_personal (3: FLIXBUS)
INSERT INTO Personal (meno, priezvisko, email, heslo, id_dopravca_personal)
VALUES ('Mia', 'Bořecká', 'mia.borecka@seznam.cz', 'boreckaM2001', '3'); -- id_dopravca_personal (3: FLIXBUS)

-- REGIOJET cisla vozidiel: 1-4
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('61', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', 'Brno - ÚAN Zvonařka', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('59', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', 'Brno - ÚAN Zvonařka', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('47', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', 'Brno - ÚAN Zvonařka', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('55', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', 'Brno - ÚAN Zvonařka', 1);

-- LEO EXPRESS cisla vozidiel: 5
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('51', 'Business Class v autobusoch: Potrebujete v pokoji pracovať a chcete si užiť vybrané občerstvenie zadarmo? Doprajte si nadštandardný komfort i v priebehu cesty autobusom. Služby navyše v Business Class: Kráľovský priestor pre nohy. Balíček s občerstvením v cene lístka (balíček obsahuje ďalší nealkoholický nápoj, sladký a slaný snack). Na vybraných spojoch navyše. Luxusné kožené sedadlá s dodatočnou opierkou hlavy. Stolíky prispôsobené na prácu s notebookom. Stevard s prednostnou obsluhou.', 'Olomouc - hl.nádr.', 2);

-- FLIX BUS cisla vozidiel: 6-11
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('54', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', 'Liberec - aut.nádr.', 3);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('50', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', 'Liberec - aut.nádr.', 3);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('56', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', 'Jihlava - aut.nádr.', 3);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', 'Praha - Hlavní nádraží', 3);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', 'Brno - ÚAN Zvonařka', 3);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('52', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', 'Brno - ÚAN Zvonařka', 3);


-- BRNO -> PRAHA, REGIOJET (id 1)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('1');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('1', '1', '12:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('1', '10', '14:30'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('1', '1'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('1');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('2', '1', '9:30'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('2', '10', '12:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('2', '2'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('1');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('3', '1', '14:50'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('3', '10', '17:30'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('3', '3'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('1');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('4', '1', '18:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('4', '10', '20:30'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('4', '4'); -- regio, Brno-Praha

-- OLOMOUC -> OSTRAVA, LEO EXPRESS (id 2)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('5', '6', '9:20'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('5', '7', '10:30'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '5'); -- leo express, Olomouc-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('6', '6', '12:10'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('6', '7', '13:20'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '6'); -- leo express, Olomouc-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('7', '6', '15:45'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('7', '7', '16:55'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '7'); -- leo express, Olomouc-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('8', '6', '18:50'); -- Olomouc
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('8', '7', '20:00'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '8'); -- leo express, Olomouc-Ostrava

-- OSTRAVA -> OLOMOUC, LEO EXPRESS (id 2)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('9', '7', '10:40'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('9', '6', '11:50'); -- Olomouc
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '9'); -- leo express, Ostrava-Olomouc

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('10', '7', '13:30'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('10', '6', '14:40'); -- Olomouc
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '10'); -- leo express, Ostrava-Olomouc

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('2');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('11', '7', '17:20'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('11', '6', '18:30'); -- Olomouc
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('5', '11'); -- leo express, Ostrava-Olomouc

-- LIBEREC -> HRADEC KRALOVE -> PARDUBICE, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '5', '9:30'); -- Liberec
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '2', '11:25'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '1', '11:55'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '10', '11:56'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('12', '8', '12:24'); -- Pardubice
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '12'); -- flix bus, Liberec-Hradec Kralove-

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('13', '5', '13:30'); -- Liberec
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('13', '2', '15:30'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('13', '8', '16:29'); -- Pardubice
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '13'); -- flix bus, Liberec-Hradec Kralove-Pardubice

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
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
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('15', '8', '13:40'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('15', '2', '14:20'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('15', '5', '16:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '15'); -- flix bus, Liberec-Hradec Kralove-Pardubice

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '8', '6:42'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '2', '7:35'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '5', '9:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '16'); -- flix bus, Pardubice-Hradec Kralove-Liberec

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '8', '17:35'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '2', '18:35'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '5', '20:25'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '17'); -- flix bus, Pardubice-Hradec Kralove-Liberec

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
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
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '3', '7:40'); -- Jihlava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '4', '11:17'); -- Kromeriz
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('8', '19'); -- flix bus, Jihlava-Kromeriz

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('20', '3', '15:30'); -- Jihlava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('20', '4', '18:16'); -- Kromeriz
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('8', '20'); -- flix bus, Jihlava-Kromeriz

-- KROMERIZ -> JIHLAVA, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('21', '4', '12:10'); -- Kromeriz
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('21', '3', '15:20'); -- Jihlava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('8', '21'); -- flix bus, Kromeriz-Jihlava

-- PRAHA -> PLZEN, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('22', '10', '8:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('22', '9', '9:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '22'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('23', '10', '10:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('23', '9', '11:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '23'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('24', '10', '12:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('24', '9', '13:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '24'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('25', '10', '14:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('25', '9', '15:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '25'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('26', '10', '16:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('26', '9', '17:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '26'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('27', '10', '18:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('27', '9', '19:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '27'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('28', '10', '20:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('28', '9', '21:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '28'); -- flix bus, Praha-Plzen

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('29', '10', '22:00'); -- Praha
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('29', '9', '23:00'); -- Plzen
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '29'); -- flix bus, Praha-Plzen

-- PLZEN -> PRAHA, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('30', '9', '7:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('30', '10', '8:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '30'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('31', '9', '9:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('31', '10', '10:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '31'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('32', '9', '11:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('32', '10', '12:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '32'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('33', '9', '13:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('33', '10', '14:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '33'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('34', '9', '15:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('34', '10', '16:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '34'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('35', '9', '17:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('35', '10', '18:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '35'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('36', '9', '19:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('36', '10', '20:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '36'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('37', '9', '21:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('37', '10', '22:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '37'); -- flix bus, Plzen-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('38', '9', '23:00'); -- Plzen
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('38', '10', '23:59'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('9', '38'); -- flix bus, Plzen-Praha

-- BRNO -> ZLIN -> OSTRAVA, FLIX BUS (id 3)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('39', '1', '9:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('39', '11', '10:45'); -- Zlin
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('39', '7', '14:10'); -- Ostrava
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('10', '39'); -- flix bus, Brno-Zlin-Ostrava

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
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
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('41', '7', '14:15'); -- Ostrava
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('41', '11', '17:45'); -- Zlin
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('41', '1', '20:00'); -- Brno
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('10', '41'); -- flix bus, Ostrava-Zlin-Brno

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
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
VALUES ('1', '1');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('2', '2');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('3', '3');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('4', '4');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '5');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '6');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '7');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '8');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '9');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '10');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('5', '11');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('6', '12');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('7', '13');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('6', '14');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('6', '15');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('6', '16');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('7', '17');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('7', '18');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('8', '19');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('8', '20');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('8', '21');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '22');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '23');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '24');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '25');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '26');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '27');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '28');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '29');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '30');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '31');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '32');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '33');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '34');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '35');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '36');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '37');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('9', '38');

INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('10', '39');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('11', '40');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('10', '41');
INSERT INTO Personal_Spoj (id_personalu, id_spoju)
VALUES ('11', '42');




