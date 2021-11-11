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
    cas_prejazdu VARCHAR(20),
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
VALUES ('Admin', 'adminko', 'admin@admin.com', 'password');

INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Brno - ÚAN Zvonařka');
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Český Krumlov - aut.nádr.');
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
INSERT INTO Zastavky (nazov_zastavky)
VALUES ('Ústí nad Labem');


INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Patrik', 'Jacola', 'patrikus@jacolus.sk', '2BitStudent');
INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Veronika', 'Marková', 'markovav@gmail.com', 'novakovaV7891');
INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Eleonóra', 'Trúfalová', 'elitra@gmail.com', 'Mauricius2004');
INSERT INTO Personal (meno, priezvisko, email, heslo)
VALUES ('Jakub', 'Davinič', 'davinjacob@seznam.cz', 'petrone14H');

INSERT INTO Dopravca (meno, priezvisko, email, heslo)
VALUES ('Regio', 'Jet', 'regiojet@regiojet.com', 'studentAgency2011ToTheInfinityAndBeyond');
INSERT INTO Dopravca (meno, priezvisko, email, heslo)
VALUES ('leo', 'express', 'expressileo@leoexpress.com', 'Kah9-Cy.a55');
INSERT INTO Dopravca (meno, priezvisko, email, heslo)
VALUES ('Flix', 'BUS', 'flixmotors@flixbus.com', 'flexiBuZzes4596');

INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES (61, 'Luxusní žluté autobusy. Vozový park v korporátní žluté barvě tvoří španělské autobusy Irizar na podvozcích Scania nebo Volvo s luxusní výbavou Fun&Relax. Vozový park každoročně obměňujeme o další nové autobusy ve stylu Fun&Relax. V červnu 2020 jsme přivítali v naší žluté flotile dalších 10 zbrusu nových vozů nejnovější modelové řady Irizar i8. Autobusy jsou 61místné s pohodlnými celokoženými sedačkami a monitory SDHD s vysokým rozlišením. Každé sedadlo má také nově nainstalovanou svou vlastní zásuvku. Bezpečnostní standardy posílilo nejmodernější špičkové samohasící zařízení motorového prostoru. Nové vozy navýšily počet autobusů Irizar i8 až na 55 vozů. Cestující čeká luxusní a moderní design, který na první pohled zaujme výraznějšími a ostřejšími liniemi. Interiér přináší nadstandardní pohodlí. Komforní sedadla jsou plně nastavitelná a v každém z nich je zabudovaná obrazovka s multimediálním zábavním systémem, v němž jsou dostupné filmy, seriály nebo online hry. V autobusech je bezplatně dostupné také připojení k internetu. Samozřejmostí je výkonný klimatizační systém, LED osvětlení a toaleta. Komfort a bezpečnost našich autobusů je pro nás prioritou, proto pravidelně investujeme do obnovy vozového parku. Novou generaci vozů Irizar i8 na podvozcích Volvo nebo Scania jsme nasadili do provozu jako první autobusoví dopravci ve střední Evropě. Autobusy Fun&Relax nabízíme i k pronájmu pro skupinové zájezdy nebo k prodeji.', ' ', 1);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES (51, 'Business Class v autobusoch: Potrebujete v pokoji pracovať a chcete si užiť vybrané občerstvenie zadarmo? Doprajte si nadštandardný komfort i v priebehu cesty autobusom. Služby navyše v Business Class: Kráľovský priestor pre nohy. Balíček s občerstvením v cene lístka (balíček obsahuje ďalší nealkoholický nápoj, sladký a slaný snack). Na vybraných spojoch navyše. Luxusné kožené sedadlá s dodatočnou opierkou hlavy. Stolíky prispôsobené na prácu s notebookom. Stevard s prednostnou obsluhou.', ' ', 2);
INSERT INTO Vozidlo (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo)
VALUES (54, 'Naše služby v autobuse s FlixBusom Pri ceste FlixBusom máte zaručené najlepšie služby. Vo všetkých našich autobusoch nájdete bezplatnú Wi-fi, extra priestor na nohy, občerstvenie a nápoje za nízke ceny, mnoho zásuviek a dostatok priestoru na batožinu. Vďaka bezplatnej Wi-fi v našich autobusoch sa vyhnete nude – môžete stráviť cestu surfovaním po internete, online pokecom s priateľmi a prezeraním emailov, to všetko so 4G rýchlosťou! FlixBus vám garantuje tiež sedadlo s extra priestorom na nohy. Naše moderné autobusy sú vybavené pohodlnými sedadlami a množstvom priestoru. Všetky sedadlá majú nastaviteľné operadlá a sú pohodlné aj na dlhších cestách. Vo Flixbuse sa o vás vždy dobre postaráme: na palube niektorých autobusov si môžete kúpiť občerstvenie a nápoje za nízke ceny. Chcete surfovať po internete, pokecať si online s priateľmi alebo pracovať na notebooku, ale batéria je vybitá? Žiadny problém! Hľadajte symbol zásuvky alebo sa opýtajte našich priateľských šoférov, kde nájdete jednu z mnohých zásuviek v autobusoch FlixBus. Ešte bude chvíľu trvať, kým sa dostanete na svoju zástavku? Žiadny dôvod na nervozitu! Vo všetkých autobusoch FlixBus je toaleta. Naše FlixBus autobusy majú dostatok priestoru na batožinu. Uložte si príručnú batožinu do priehradiek nad hlavou a priateľskí šoféri vám pomôžu naložiť normálnu batožinu. ', ' ', 3);