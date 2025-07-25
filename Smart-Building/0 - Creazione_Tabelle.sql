SET GLOBAL event_scheduler = ON;
DROP TABLE IF EXISTS CalamitaPassate;
DROP TABLE IF EXISTS PericoliAmbientali;
DROP TABLE IF EXISTS Finestra;
DROP TABLE IF EXISTS Porta;
DROP TABLE IF EXISTS Alert;
DROP TABLE IF EXISTS Dati;
DROP TABLE IF EXISTS Sensore;
DROP TABLE IF EXISTS FattoSu;
DROP TABLE IF EXISTS Vano;
DROP TABLE IF EXISTS Piano;
DROP TABLE IF EXISTS MaterialeGenerico;
DROP TABLE IF EXISTS Piastrella;
DROP TABLE IF EXISTS Parquet;
DROP TABLE IF EXISTS Pietra;
DROP TABLE IF EXISTS Intonaco;
DROP TABLE IF EXISTS Mattone;
DROP TABLE IF EXISTS Materiali;
DROP TABLE IF EXISTS Orario1;
DROP TABLE IF EXISTS Orario2;
DROP TABLE IF EXISTS Turno;
DROP TABLE IF EXISTS Lavora1;
DROP TABLE IF EXISTS Lavora2;
DROP TABLE IF EXISTS CapoCantiere;
DROP TABLE IF EXISTS Operaio;
DROP TABLE IF EXISTS Lavoro;
DROP TABLE IF EXISTS Assegnato;
DROP TABLE IF EXISTS Responsabile;
DROP TABLE IF EXISTS StadioAvanzamento;
DROP TABLE IF EXISTS Associato;
DROP TABLE IF EXISTS Progetto;
DROP TABLE IF EXISTS Edificio;
DROP TABLE IF EXISTS AreaGeografica;

CREATE TABLE AreaGeografica(
	Nome VARCHAR(100) NOT NULL,
    PRIMARY KEY(Nome)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE CalamitaPassate(
	Data TIMESTAMP NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    Area VARCHAR(100) NOT NULL,
    Intensita FLOAT NOT NULL,
    Epicentro VARCHAR(100) NOT NULL,
    PRIMARY KEY(Data,Tipo,Area),
    CONSTRAINT FK_AreaCalamita
    FOREIGN KEY(Area)
    REFERENCES AreaGeografica(Nome)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE PericoliAmbientali(
	Data TIMESTAMP NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    Area VARCHAR(100) NOT NULL,
    Coefficiente FLOAT NOT NULL,
    PRIMARY KEY (Data,Area,Tipo),
    CONSTRAINT FK_AreaPericoli
    FOREIGN KEY(Area)
    REFERENCES AreaGeografica(Nome)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Edificio(
	CodiceEdificio VARCHAR(6) NOT NULL,
	Area VARCHAR(100) NOT NULL,
	Tipo VARCHAR(100) NOT NULL,
	PRIMARY KEY(CodiceEdificio),
    CONSTRAINT FK_AreaEdificio
    FOREIGN KEY (Area)
    REFERENCES AreaGeografica(Nome)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Piano(
	Edificio VARCHAR(6) NOT NULL,
	Numero INTEGER NOT NULL,
	Pianta VARCHAR(8) NOT NULL,
	PRIMARY KEY (Numero,Edificio),
	CONSTRAINT FK_EdificioPiano
	FOREIGN KEY (Edificio)
		REFERENCES Edificio(CodiceEdificio)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Vano(
	CodiceVano VARCHAR(8) NOT NULL,
	Piano INTEGER NOT NULL,
	Edificio VARCHAR(6) NOT NULL,
	AltezzaMax DECIMAL(5,3),
	LarghezzaMax DECIMAL(5,3) NOT NULL,
	LunghezzaMax DECIMAL(5,3) NOT NULL,
	Scopo VARCHAR(100),
	CHECK (AltezzaMax > 0  OR AltezzaMax IS NULL),
	CHECK (LarghezzaMax > 0 AND LunghezzaMax > 0),
	PRIMARY KEY (CodiceVano),
	CONSTRAINT FK_PianoVano
    FOREIGN KEY(Edificio,Piano)
    REFERENCES Piano(Edificio,Numero)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Finestra(
	Vano VARCHAR(8) NOT NULL,
    CodiceFinestra VARCHAR(2) NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    Orientamento VARCHAR(2) NOT NULL,
    CHECK (Orientamento = "N" OR Orientamento="NE" OR Orientamento = "E" OR Orientamento = "SE" OR
			Orientamento = "S" OR Orientamento = "SO" OR Orientamento = "O" OR Orientamento = "NO"),
	PRIMARY KEY (Vano,CodiceFinestra),
    CONSTRAINT FK_VanoFinestra
    FOREIGN KEY (Vano)
    REFERENCES Vano(CodiceVano)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Porta(
	Vano1 VARCHAR(8) NOT NULL,
    CodicePorta VARCHAR(3) NOT NULL,
    Vano2 VARCHAR(8),
    Tipo VARCHAR(100) NOT NULL,
    Altezza DECIMAL(5,3) NOT NULL,
    Lunghezza DECIMAL (5,3) NOT NULL,
    X DECIMAL (5,3) NOT NULL,
    Y DECIMAL (5,3) NOT NULL,
    CHECK( Altezza > 0 AND Lunghezza > 0),
    CHECK( X>=0 AND Y>=0 ),
    PRIMARY KEY (Vano1, CodicePorta),
    CONSTRAINT FK_Vano1Porta
    FOREIGN KEY (Vano1)
    REFERENCES Vano(CodiceVano)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT FK_Vano2Porta
    FOREIGN KEY (Vano2)
    REFERENCES Vano(CodiceVano)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Sensore(
	CodiceSensore VARCHAR(2) NOT NULL,
    Vano VARCHAR(8) NOT NULL,
    Soglia FLOAT NOT NULL,
    Calamitoso BOOLEAN NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    PRIMARY KEY (Vano,CodiceSensore),
    CONSTRAINT FK_VanoSensore
    FOREIGN KEY (Vano)
    REFERENCES Vano(CodiceVano)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Dati(
	Sensore VARCHAR(2) NOT NULL,
    Vano VARCHAR(8) NOT NULL,
    Data TIMESTAMP NOT NULL,
    Valore FLOAT NOT NULL,
    PRIMARY KEY(Vano,Sensore,Data),
    CONSTRAINT FK_SensoreDati
    FOREIGN KEY (Vano,Sensore)
    REFERENCES Sensore(Vano,CodiceSensore)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Alert(
	Sensore VARCHAR(2) NOT NULL,
    Vano VARCHAR(8) NOT NULL,
    Data TIMESTAMP NOT NULL,
	Valore FLOAT NOT NULL,
    PRIMARY KEY (Sensore,Vano,Data),
    CONSTRAINT FK_DatiAlert
    FOREIGN KEY(Vano,Sensore,Data)
    REFERENCES Dati(Vano,Sensore,Data)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Progetto(
	CodiceProgetto VARCHAR(6) NOT NULL,
    DataPresentazione DATE NOT NULL,
    DataApprovazione DATE NOT NULL,
    DataInizio DATE DEFAULT NULL,
    DataFineStimata DATE DEFAULT NULL,
    DataFine DATE DEFAULT NULL,
    CostoProgetto DECIMAL(9,2) NOT NULL DEFAULT 0,
    CHECK(CostoProgetto >= 0),
    CHECK(DataPresentazione <= DataApprovazione),
    CHECK(DataApprovazione <=DataInizio OR DataInizio IS NULL),
    CHECK(DataInizio<=DataFine OR DataFine IS NULL),
    CHECK(DataInizio<=DataFineStimata OR DataFineStimata IS NULL),
    PRIMARY KEY(CodiceProgetto)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Associato(
	Progetto VARCHAR(6) NOT NULL,
    Edificio VARCHAR(6) NOT NULL,
    PRIMARY KEY(Progetto,Edificio),
    CONSTRAINT FK_ProgettoAssociato
    FOREIGN KEY (Progetto)
    REFERENCES Progetto(CodiceProgetto)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
	CONSTRAINT FK_EdificioAssociato
    FOREIGN KEY (Edificio)
    REFERENCES EDificio(CodiceEdificio)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE StadioAvanzamento(
	Progetto VARCHAR(6) NOT NULL,
    Fase INTEGER NOT NULL,
    DataInizio DATE DEFAULT NULL,
    DataFineStimata DATE DEFAULT NULL,
    DataFine DATE DEFAULT NULL,
    CHECK(DataInizio<=DataFine OR DataFine IS NULL),
	CHECK(DataInizio<=DataFineStimata OR DataFineStimata IS NULL),
    PRIMARY KEY(Progetto,Fase),
    CONSTRAINT FK_ProgettoStadio
    FOREIGN KEY(Progetto)
    REFERENCES Progetto(CodiceProgetto)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;
    
CREATE TABLE Lavoro(
	Progetto VARCHAR(6) NOT NULL,
    Stadio INTEGER NOT NULL,
    Numero INTEGER NOT NULL,
    DataInizio DATE NOT NULL,
    DataFineStimata DATE DEFAULT NULL,
    DataFine DATE DEFAULT NULL,
    Costo DECIMAL(8,2) NOT NULL DEFAULT 0,
    Descrizione VARCHAR(100) NOT NULL,
    CHECK(Costo>=0),
    CHECK(DataInizio<=DataFine OR DataFine IS NULL),
	CHECK(DataInizio<=DataFineStimata OR DataFineStimata IS NULL),
    CHECK(left(Descrizione,1)='S' OR left(Descrizione,1)='I' OR left(Descrizione,1)='D' OR left(Descrizione,1)='F'),
    PRIMARY KEY (Progetto,Stadio,Numero),
    CONSTRAINT FK_StadioLavoro
    FOREIGN KEY(Progetto,Stadio)
    REFERENCES StadioAvanzamento(Progetto,Fase)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE FattoSu(	
	Vano VARCHAR(8) NOT NULL,
	Progetto VARCHAR(6) NOT NULL,
	Stadio INTEGER NOT NULL,
	Lavoro INTEGER NOT NULL,
	PRIMARY KEY(Vano,Progetto,Stadio,Lavoro),
	CONSTRAINT FK_VanoFatto
	FOREIGN KEY(Vano)
	REFERENCES Vano(CodiceVano)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT FK_LavoroFatto
	FOREIGN KEY(PRogetto,Stadio,Lavoro)
	REFERENCES Lavoro(Progetto,Stadio,Numero)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Materiali(
	IDLotto VARCHAR(8) NOT NULL,
	Progetto VARCHAR(6) NOT NULL,	
	Stadio INTEGER NOT NULL,
	Lavoro INTEGER NOT NULL,
	Costo DECIMAL(7,2) NOT NULL,
	DataAcquisto DATE NOT NULL,
	Fornitore VARCHAR(100) NOT NULL,
	QuantitaAcquistata DECIMAL(10,4) NOT NULL,
	Copertura BOOLEAN NOT NULL,
	Pavimentabile BOOLEAN NOT NULL,
	Portante BOOLEAN NOT NULL,
	CHECK (Costo>0),
	CHECK (QuantitaAcquistata > 0),
    CHECK ((Pavimentabile=TRUE AND Copertura=FALSE AND Portante=FALSE) OR 
		   (Pavimentabile=FALSE AND Copertura=TRUE AND Portante=FALSE) OR 
           (Pavimentabile=FALSE AND Copertura=FALSE AND Portante=TRUE)),
	PRIMARY KEY(IDLotto),
	CONSTRAINT FK_LavoroMateriali
	FOREIGN KEY(Progetto,Stadio,Lavoro)
	REFERENCES Lavoro(Progetto,Stadio,Numero)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE MaterialeGenerico(
	Lotto VARCHAR(8) NOT NULL,
	Larghezza DECIMAL(5,2) NOT NULL,
	Lunghezza DECIMAL(5,2) NOT NULL,
	Altezza DECIMAL(5,2) NOT NULL,
	Descrizione VARCHAR(100) NOT NULL,
	CHECK(Larghezza > 0),
	CHECK(Lunghezza > 0),
	CHECK(Altezza > 0),
	PRIMARY KEY (Lotto),
	CONSTRAINT FK_MaterialiGenerico
	FOREIGN KEY(Lotto)
	REFERENCES Materiali(IDLotto)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Piastrella(
	Lotto VARCHAR(8) NOT NULL,
	Fantasia VARCHAR(100) NOT NULL,
	Forma VARCHAR(100) NOT NULL,
	Materiale VARCHAR(100) NOT NULL,
	Fuga DECIMAL(4,3) NOT NULL,
	CHECK (Fuga>0),
	PRIMARY KEY (Lotto),
	CONSTRAINT FK_MaterialiPiastrella
	FOREIGN KEY(Lotto)
	REFERENCES Materiali(IDLotto)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Parquet(
	Lotto VARCHAR(8) NOT NULL,
	Tipo VARCHAR(100) NOT NULL,
	PRIMARY KEY(Lotto),
	CONSTRAINT FK_MaterialiParquet
	FOREIGN KEY(Lotto)
	REFERENCES Materiali(IDLotto)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Pietra(
	Lotto VARCHAR(8) NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    SuperficieMedia DECIMAL(3,1) NOT NULL,
    CHECK (SuperficieMedia > 0 ),
    PRIMARY KEY(Lotto),
	CONSTRAINT FK_MaterialiPietra
	FOREIGN KEY(Lotto)
	REFERENCES Materiali(IDLotto)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Intonaco(
	Lotto VARCHAR(8) NOT NULL,
    Colore VARCHAR(100) NOT NULL,
    Spessore DECIMAL(4,3) NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    CHECK (Spessore > 0),
	PRIMARY KEY(Lotto),
	CONSTRAINT FK_MaterialiIntonaco
	FOREIGN KEY(Lotto)
	REFERENCES Materiali(IDLotto)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Mattone(
	Lotto VARCHAR(8) NOT NULL,
	Materiale VARCHAR(100) NOT NULL,
	Alveolatura VARCHAR(100) NOT NULL,
	Larghezza DECIMAL(5,2) NOT NULL,
	Lunghezza DECIMAL(5,2) NOT NULL,
	ALtezza DECIMAL(5,2) NOT NULL,
	CHECK(Larghezza > 0),
	CHECK(Lunghezza > 0),
	CHECK(Altezza > 0),
	PRIMARY KEY(Lotto),
	CONSTRAINT FK_MaterialiMattone
	FOREIGN KEY(Lotto)
	REFERENCES Materiali(IDLotto)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE CapoCantiere(
	Matricola VARCHAR(6) NOT NULL,
    Nome VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20) NOT NULL,
    Paga DECIMAL(5,2) NOT NULL,
    Esperienza INTEGER NOT NULL DEFAULT 0,
    MaxLavoratori INTEGER NOT NULL DEFAULT 0,
    CHECK(Paga>0),
    PRIMARY KEY(Matricola)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Operaio(
	Matricola VARCHAR(8) NOT NULL,
    Nome VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20) NOT NULL,
    Paga DECIMAL(5,2) NOT NULL,
    CHECK(Paga>0),
    PRIMARY KEY(Matricola)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Lavora1(
	CapoCantiere VARCHAR(6) NOT NULL,
    Progetto VARCHAR(6) NOT NULL,
    Stadio INTEGER NOT NULL,
    Lavoro INTEGER NOT NULL,
    PRIMARY KEY(CapoCantiere,Progetto,Stadio,Lavoro),
    CONSTRAINT FK_LavoroLavora1
    FOREIGN KEY(Progetto,Stadio,Lavoro)
    REFERENCES Lavoro(Progetto,Stadio,Numero)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT FK_CapoCantiereLavoro1
	FOREIGN KEY(CapoCantiere)
    REFERENCES CapoCantiere(Matricola)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Lavora2(
	Operaio VARCHAR(8) NOT NULL,
    Progetto VARCHAR(6) NOT NULL,
    Stadio INTEGER NOT NULL,
    Lavoro INTEGER NOT NULL,
    PRIMARY KEY(Operaio,Progetto,Stadio,Lavoro),
    CONSTRAINT FK_LavoroLavora2
    FOREIGN KEY(Progetto,Stadio,Lavoro)
    REFERENCES Lavoro(Progetto,Stadio,Numero)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT FK_OperaioLavora2
	FOREIGN KEY(Operaio)
    REFERENCES Operaio(Matricola)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Turno(
	Orario VARCHAR(11) NOT NULL,
    PRIMARY KEY(Orario),
    CHECK(strcmp(substring(Orario,4,2),"00")=0),
    CHECK(strcmp(substring(Orario,10,2),"00")=0),
    CHECK(str_to_date(left(Orario,5),"%H:%i")<str_to_date(right(Orario,5),"%H:%i")),
    CHECK((str_to_date(left(Orario,5),"%H:%i")>= str_to_date("00:00","%H:%i") AND 
       str_to_date(left(Orario,5),"%H:%i")<= str_to_date("22:00","%H:%i")) AND
       (str_to_date(right(Orario,5),"%H:%i")>= str_to_date("01:00","%H:%i") AND 
       str_to_date(right(Orario,5),"%H:%i")<= str_to_date("23:00","%H:%i")))
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Orario1(
	CapoCantiere VARCHAR(6) NOT NULL,
    Orario VARCHAR(11) NOT NULL,
    
    PRIMARY KEY(CapoCantiere,Orario),
    CONSTRAINT FK_CapoCantiereOrario1
    FOREIGN KEY(CapoCantiere)
    REFERENCES CapoCantiere(Matricola)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT FK_TurnoOrario1
    FOREIGN KEY (Orario)
    REFERENCES Turno(Orario)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Orario2(
	Operaio VARCHAR(8) NOT NULL,
    Orario VARCHAR(11) NOT NULL,
    PRIMARY KEY(Operaio,Orario),
    CONSTRAINT FK_OperaioOrario2
    FOREIGN KEY(Operaio)
    REFERENCES Operaio(Matricola)
		ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT FK_TurnoOrario2
    FOREIGN KEY (Orario)
    REFERENCES Turno(Orario)
		ON UPDATE CASCADE
        ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Responsabile(
	Matricola VARCHAR(4) NOT NULL,
    Nome VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20) NOT NULL,
    Paga DECIMAL(5,2) NOT NULL,
    CHECK(Paga > 0),
    PRIMARY KEY(Matricola)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Assegnato(
	Responsabile VARCHAR(4) NOT NULL,
    Progetto VARCHAR(6) NOT NULL,
    Stadio INTEGER NOT NULL,
    PRIMARY KEY (Responsabile, Progetto, Stadio),
    CONSTRAINT FK_ResponsabileAssegnato
    FOREIGN KEY (Responsabile)
    REFERENCES Responsabile(Matricola)
		ON UPDATE CASCADE
        ON DELETE NO ACTION,
	CONSTRAINT FK_StadioAssegnato
    FOREIGN KEY (Progetto, Stadio)
    REFERENCES StadioAvanzamento(Progetto, Fase)
		ON UPDATE CASCADE
        ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;