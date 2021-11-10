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
    id VARCHAR(40) PRIMARY KEY,-- primarni klic
    cenova_kategoria VARCHAR(40),
    id_dopravca_spoje INTEGER,
    CONSTRAINT PK_id_dopravca_spoje
		FOREIGN KEY (id_dopravca_spoje) REFERENCES Dopravca (id)
		ON DELETE CASCADE
); 
CREATE TABLE Zastavky(
    id VARCHAR(40) PRIMARY KEY,-- primarni klic
    nazov_zastavky VARCHAR (30),
    cas_prejazdu VARCHAR(20),
    geograficka_poloha VARCHAR(40)
); 
CREATE TABLE Jizdenka(
    id INT(11) NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    meno VARCHAR(40) NOT NULL,
    id_spoj_jizdenky VARCHAR (40),
    id_zastavky_jizdenky VARCHAR (40),
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
    id_zastavky_navrhy VARCHAR (40),
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
    popis_vozidla VARCHAR(100),
    aktualna_poloha VARCHAR(100),
    id_dopravca_vozidlo INTEGER,
    CONSTRAINT PK_id_dopravca_vozidlo
		FOREIGN KEY (id_dopravca_vozidlo) REFERENCES Dopravca (id)
		ON DELETE CASCADE
);

CREATE TABLE Spoj_Zastavka(
    id_spoju VARCHAR (40),-- primarni klic
    id_zastavky VARCHAR(40),-- primarni klic
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
    id_spoju VARCHAR(40),-- primarni klic
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
    id_spoju VARCHAR(40),-- primarni klic
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
