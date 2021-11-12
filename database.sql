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
    meno VARCHAR(40) NOT NULL,
    priezvisko VARCHAR(40) NOT NULL,
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
    geograficka_poloha VARCHAR(40)
);
CREATE TABLE Jizdenka(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    meno VARCHAR(40) NOT NULL,
    id_spoj_jizdenky INT,
    id_zastavky_jizdenky INT (40),
    id_personal_jizdenka INTEGER,
    id_cestujuci_jizdenka INTEGER,
    CONSTRAINT PK_id_spoj_jizdenky
		FOREIGN KEY (id_spoj_jizdenky) REFERENCES Spoj (id)
		ON DELETE CASCADE,
    CONSTRAINT PK_id_zastavky_jizdenky
		FOREIGN KEY (id_zastavky_jizdenky) REFERENCES Zastavky (id)
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
    id_zastavky_navrhy INTEGER,
    id_dopravca_navrhy INTEGER,
    id_administrator_navrh INTEGER,
    CONSTRAINT PK_id_zastavky_navrhy
		FOREIGN KEY (id_zastavky_navrhy) REFERENCES Zastavky (id)
		ON DELETE CASCADE,
    CONSTRAINT PK_id_dopravca_navrhy
		FOREIGN KEY (id_dopravca_navrhy) REFERENCES Dopravca (id)
		ON DELETE CASCADE,
    CONSTRAINT PK_id_administrator_navrh
		FOREIGN KEY (id_administrator_navrh) REFERENCES Administrator (id)
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

INSERT INTO Administrator (meno, priezvisko, email, heslo)
VALUES ('Admin', 'Admin', 'admin@admin.com', 'password');

INSERT INTO Cestujuci (meno, priezvisko, email, heslo)
VALUES ('Ko', 'Kotko', 'debilko@dement.dementor', 'pstrosS5');

INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Brno - ÚAN Zvonařka');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Hradec Králové - Terminál HD');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Jihlava - aut.nádr.');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Kroměříž - aut.nádr.');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Liberec - aut.nádr.');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Olomouc - hl.nádr.');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Ostrava - ÚAN');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Pardubice - hl.nádr.');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Plzeň - CAN');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Praha - Hlavní nádraží');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Zlín - aut.nádr.');


INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Patrik', 'Jacola', 'patrikus@jacolus.sk', '2BitStudent');
INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Veronika', 'Marková', 'markovav@gmail.com', 'novakovaV7891');
INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Eleonóra', 'Trúfalová', 'elitra@gmail.com', 'Mauricius2004');
INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Jakub', 'Davinič', 'davinjacob@seznam.cz', 'petrone14H');

INSERT INTO Dopravca (meno, priezvisko, email, heslo)
VALUES ('Regio', 'Jet', 'regiojet@regiojet.com', 'studentAgency2011ToTheInfinityAndBeyond'); -- dopravca c.1
INSERT INTO Dopravca (meno, priezvisko, email, heslo)
VALUES ('leo', 'express', 'expressileo@leoexpress.com', 'Kah9-Cy.a55'); -- dopravca c.2
INSERT INTO Dopravca (meno, priezvisko, email, heslo)
VALUES ('Flix', 'BUS', 'flixmotors@flixbus.com', 'flexiBuZzes4596'); -- dopravca c.3

-- REGIOJET
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('61', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', ' ', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('59', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', ' ', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('47', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', ' ', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('55', 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', ' ', 1);

-- LEO EXPRESS
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('51', 'Business Class v autobusoch: Potrebujete v pokoji pracovať a chcete si užiť vybrané občerstvenie zadarmo? Doprajte si nadštandardný komfort i v priebehu cesty autobusom. Služby navyše v Business Class: Kráľovský priestor pre nohy. Balíček s občerstvením v cene lístka (balíček obsahuje ďalší nealkoholický nápoj, sladký a slaný snack). Na vybraných spojoch navyše. Luxusné kožené sedadlá s dodatočnou opierkou hlavy. Stolíky prispôsobené na prácu s notebookom. Stevard s prednostnou obsluhou.', ' ', 2);

-- FLIX BUS
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('54', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', ' ', 3);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES ('50', 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', ' ', 3);


-- BRNO -> PRAHA, REGIOJET (id 1)
INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('1');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('1', '1', '9:30'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('1', '10', '12:00'); -- Praha
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('1', '1'); -- regio, Brno-Praha

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('1');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('2', '1', '12:00'); -- Brno
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('2', '10', '14:30'); -- Praha
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
VALUES ('16', '8', '13:40'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '2', '14:20'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('16', '5', '16:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '16'); -- flix bus, Liberec-Hradec Kralove-Pardubice

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '8', '6:42'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '2', '7:35'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('17', '5', '9:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('6', '17'); -- flix bus, Pardubice-Hradec Kralove-Liberec

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('18', '8', '17:35'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('18', '2', '18:35'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('18', '5', '20:25'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '18'); -- flix bus, Pardubice-Hradec Kralove-Liberec

INSERT INTO Spoj (id_dopravca_spoje)
VALUES ('3');
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '8', '9:21'); -- Pardubice
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '2', '13:25'); -- Hradec Kralove
INSERT INTO Spoj_Zastavka (id_spoju, id_zastavky, cas_prejazdu)
VALUES ('19', '5', '12:30'); -- Liberec
INSERT INTO Vozidlo_Spoj (id_vozidla, id_spoju)
VALUES ('7', '19'); -- flix bus, Pardubice-Hradec Kralove-Liberec