DROP TABLE IF EXISTS O1;
CREATE TABLE O1(ini TIME,fin TIME,ML INTEGER);
DROP TABLE IF EXISTS O2;
CREATE TABLE O2(NLav INTEGER,ini TIME, fin TIME);
INSERT INTO O2 VALUES(0,'01:00:00','23:00:00');
DROP TRIGGER IF EXISTS ControlloPorte;
DELIMITER $$
CREATE TRIGGER ControlloPorte 
BEFORE INSERT ON Porta
FOR EACH ROW
	BEGIN 
		DECLARE Lun DECIMAL(5,3);
        DECLARE Lar DECIMAL(5,3);
        SET Lun = ( SELECT	V.LunghezzaMax
					FROM    Vano V
                    WHERE	NEW.Vano1=V.CodiceVano
				  );
		SET Lar = ( SELECT	V.LarghezzaMax
					FROM    Vano V
                    WHERE	NEW.Vano1=V.CodiceVano
				  );
		IF ((NEW.X>0 AND NEW.X<Lar) AND (NEW.Y>0 AND NEW.Y<Lun)) 
           OR (NEW.X>Lar OR NEW.Y>Lun)
        THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT= "Porta Non Collocabile";
        END IF;
        IF NEW.Vano2 IS NOT NULL THEN
			IF EXISTS (SELECT *
					   FROM Porta P
                       WHERE P.Vano2=NEW.Vano1 AND P.Vano1=NEW.Vano2 AND P.CodicePorta=NEW.CodicePorta
                       )
			THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT="Porta Esistente";
			END IF;
		END IF;
        IF (NEW.Vano1=NEW.Vano2) THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT="Porta non inseribile tra un vano e se stesso";
		END IF;
    END $$
DELIMITER ;

DROP TRIGGER IF EXISTS GeneraAlert;
DELIMITER $$
CREATE TRIGGER GeneraAlert
AFTER INSERT ON Dati
FOR EACH ROW
	BEGIN 
		DECLARE V FLOAT DEFAULT 0;
        DECLARE S FLOAT DEFAULT 0;
        SET V= NEW.Valore;
        SET S= (SELECT S.Soglia 
			    FROM Sensore S
                WHERE S.CodiceSensore=NEW.Sensore AND NEW.Vano=S.Vano
                );
		IF V>S THEN 
			INSERT INTO Alert VALUES(NEW.Sensore,NEW.Vano,NEW.Data,NEW.Valore);
		END IF;
    END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ControlloCalamitoso;
DELIMITER $$
CREATE TRIGGER ControlloCalamitoso
BEFORE INSERT ON Sensore
FOR EACH ROW
	BEGIN 
		IF NEW.Calamitoso = TRUE THEN
			IF EXISTS (SELECT *
					   FROM Sensore S1 INNER JOIN Vano V1 ON V1.CodiceVano=S1.Vano
					   WHERE V1.Edificio = (SELECT V2.Edificio
											FROM Vano V2
										    WHERE V2.CodiceVano=NEW.Vano
											)
						AND  S1.Calamitoso=True AND S1.Tipo=NEW.Tipo
                        )
			THEN 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Sensore Calamitoso Presente";
			END IF;
		END IF;
    END $$
DELIMITER ;

DROP TRIGGER IF EXISTS DataStadioI;
DELIMITER $$
CREATE TRIGGER DataStadioI
BEFORE INSERT ON StadioAvanzamento
FOR EACH ROW
	BEGIN
		DECLARE I DATE;
        DECLARE F DATE;
        SET I = (SELECT P.DataInizio
				 FROM Progetto P
                 WHERE P.CodiceProgetto=NEW.Progetto
				 );
		SET F= (SELECT P.DataFine
				 FROM Progetto P
                 WHERE P.CodiceProgetto=NEW.Progetto
				 );
		IF NEW.DataInizio IS NOT NULL AND (NEW.DataInizio < I  OR NEW.DataInizio >= F) THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT= "Stadio non inseribile";
		END IF;
		IF NEW.DataFine IS NOT NULL AND (NEW.DataFine>F  OR NEW.DataFine <= I) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Stadio non inseribile";
		END IF;
		IF NEW.DataFineStimata IS NOT NULL AND (NEW.DataFineStimata>F OR NEW.DataFineStimata<=I) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Stadio non inseribile";
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS DataStadioU;
DELIMITER $$
CREATE TRIGGER DataStadioU
BEFORE UPDATE ON StadioAvanzamento
FOR EACH ROW
	BEGIN
		DECLARE I DATE;
        DECLARE F DATE;
        SET I = (SELECT P.DataInizio
				 FROM Progetto P
                 WHERE P.CodiceProgetto=NEW.Progetto
				 );
		SET F= (SELECT P.DataFine
				 FROM Progetto P
                 WHERE P.CodiceProgetto=NEW.Progetto
				 );
		IF ((OLD.DataInizio IS NOT NULL AND NEW.DataInizio IS NULL) OR (OLD.DataInizio <> NEW.DataInizio))
			OR ((OLD.DataFine IS NOT NULL AND NEW.DataFine IS NULL) OR (OLD.DataFine <> NEW.DataFine))
            OR ((OLD.DataFineStimata <> NEW.DataFineStimata ) AND OLD.DataFine IS NOT NULL)
            THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT= "Stadio non modificabile";
		END IF;
        
		IF NEW.DataInizio IS NOT NULL AND (NEW.DataInizio < I  OR NEW.DataInizio >= F) THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT= "Stadio non modificabile";
		END IF;
		IF NEW.DataFine IS NOT NULL AND (NEW.DataFine>F  OR NEW.DataFine <= I) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Stadio non modificabile";
		END IF;
		IF NEW.DataFineStimata IS NOT NULL AND (NEW.DataFineStimata>F OR NEW.DataFineStimata<=I) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Stadio non modificabile";
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS DataProgettoU;
DELIMITER $$
CREATE TRIGGER DataProgettoU
BEFORE UPDATE ON progetto
FOR EACH ROW
	BEGIN
		IF  ((OLD.DataInizio <> NEW.DataInizio) OR (OLD.DataInizio IS NOT NULL AND NEW.DataInizio IS NULL))
			OR 
			((OLD.DataFine <> NEW.DataFine) OR (OLD.DataFine IS NOT NULL AND NEW.DataFine IS NULL))
			OR 
            ((OLD.DataFineStimata <> NEW.DataFineStimata ) AND OLD.DataFine IS NOT NULL)
		THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Progetto non modificabile";
		END IF;
    END $$
DELIMITER ;


DROP TRIGGER  IF EXISTS InsLavoro;
DELIMITER $$
CREATE TRIGGER InsLavoro
BEFORE INSERT ON lavoro
FOR EACH ROW
	BEGIN
		DECLARE I DATE;
        DECLARE F DATE;
        SET I= (SELECT S.DataInizio
				FROM StadioAvanzamento S
                WHERE S.Fase=NEW.Stadio AND
					  S.Progetto=NEW.Progetto
				);
		SET F=(SELECT S.DataFine
				FROM StadioAvanzamento S
                WHERE S.Fase=NEW.Stadio AND
					  S.Progetto=NEW.Progetto
				);
		IF EXISTS (SELECT *
					FROM Lavoro L
                    WHERE L.DataFine IS NULL 
                    )
			THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT= "Lavoro in corso";
		END IF;
        IF NEW.DataInizio <(SELECT MAX(L.DataFine)
						     FROM Lavoro L 
                            )
			THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT= "Lavoro in corso";
		END IF;
        IF (I IS NOT NULL AND NEW.DataInizio < I)OR 
           (F IS NOT NULL AND NEW.DataInizio >= F)THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT= "Data Errata";
		END IF;
        IF (I IS NOT NULL AND  NEW.DataFine <= I ) OR 
           (F IS NOT NULL AND NEW.DataFine >F )THEN 
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT= "Data Errata";
		END IF;
        IF I IS NULL THEN
			UPDATE StadioAvanzamento S 
			SET S.DataInizio=NEW.DataInizio
            WHERE S.Fase=NEW.Stadio AND S.Progetto=NEW.Progetto;
		END IF;
    END $$
DELIMITER ;


DROP TRIGGER IF EXISTS LavoroUpd;
DELIMITER $$
CREATE TRIGGER LavoroUpd
BEFORE UPDATE ON lavoro
FOR EACH ROW 
	BEGIN
		IF  ((OLD.DataInizio <> NEW.DataInizio) OR  NEW.DataInizio IS NULL)
			OR 
			((OLD.DataFine <> NEW.DataFine) OR (OLD.DataFine IS NOT NULL AND NEW.DataFine IS NULL))
			OR 
            ((OLD.DataFineStimata <> NEW.DataFineStimata ) AND OLD.DataFine IS NOT NULL)
		THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Lavoro non modificabile";
		END IF;
    END $$
DELIMITER ;


DROP TRIGGER  IF EXISTS ContaLavoratori;
DELIMITER $$
CREATE TRIGGER ContaLavoratori
BEFORE UPDATE ON orario1
FOR EACH ROW
BEGIN
	DECLARE ML INTEGER;
    DECLARE TS TIME;
    DECLARE hold TIME;
    DECLARE hnew TIME;
    DECLARE lold TIME;
    DECLARE lnew TIME;
    SET hold=(SELECT str_to_date(right(OLD.Orario,5),"%H:%i"));
    SET hnew=(SELECT str_to_date(right(NEW.Orario,5),"%H:%i"));
    SET lold=(SELECT str_to_date(left(OLD.Orario,5),"%H:%i"));
    SET lnew=(SELECT str_to_date(left(NEW.Orario,5),"%H:%i"));
    SET ML=(SELECT C.MaxLavoratori
			FROM Capocantiere C
            WHERE NEW.CapoCantiere = C.Matricola
            );
    INSERT INTO O1 (SELECT str_to_date(left(O.Orario,5),"%H:%i") AS ini, 
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin, SUM(C.MaxLavoratori)AS ML
								FROM Orario1 O INNER JOIN capocantiere C ON O.CapoCantiere=C.Matricola
                                GROUP BY O.Orario
				              );
	INSERT INTO O2 (SELECT COUNT(*) AS NLav, str_to_date(left(O.Orario,5),"%H:%i") AS ini,
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin
							   FROM Orario2 O
                               GROUP BY O.Orario
				              );
	IF hnew<hold THEN
		SET TS=hnew;
		ciclo: LOOP
			SET hnew=TS;
			SET TS=ADDTIME(TS,'1:00:00');
			IF(hnew=hold) THEN
				LEAVE ciclo;
			END IF;
			IF (SELECT SUM(O.NLav)
				FROM O2 O
				WHERE O.ini<=hnew AND O.fin>=TS
				)
				>
				(SELECT  SUM(O.ML) - ML
				FROM O1 O
				WHERE O.ini<=hnew AND O.fin>=TS
				)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Orario non modificabile';
			END IF;
        END LOOP ciclo;
	END IF;
    IF lnew>lold THEN
		SET TS=lold;
			ciclo1: LOOP
			SET lold=TS;
			SET TS=ADDTIME(TS,'1:00:00');
			IF(lold=lnew) THEN
				LEAVE ciclo1;
			END IF;
			IF (SELECT SUM(O.NLav)
				FROM O2 O
				WHERE O.ini<=lold AND O.fin>=TS
				)
				>
				(SELECT SUM(O.ML)-ML
				 FROM O1 O
				WHERE O.ini<=lold AND O.fin>=TS
				)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Orario non modificabile';
			END IF;
        END LOOP ciclo1;
	END IF;
     SET SQL_SAFE_UPDATES=0;
        DELETE 
        FROM O1;
        DELETE 
        FROM O2;
	 SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ContaLavoratori2;
DELIMITER $$
CREATE TRIGGER ContaLavoratori2
BEFORE UPDATE ON orario2
FOR EACH ROW
BEGIN
	DECLARE TS TIME;
    DECLARE hold TIME;
    DECLARE hnew TIME;
    DECLARE lold TIME;
    DECLARE lnew TIME;
    SET hold=(SELECT str_to_date(right(OLD.Orario,5),"%H:%i"));
    SET hnew=(SELECT str_to_date(right(NEW.Orario,5),"%H:%i"));
    SET lold=(SELECT str_to_date(left(OLD.Orario,5),"%H:%i"));
    SET lnew=(SELECT str_to_date(left(NEW.Orario,5),"%H:%i"));
    INSERT INTO O1 (SELECT str_to_date(left(O.Orario,5),"%H:%i") AS ini, 
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin, SUM(C.MaxLavoratori)AS ML
								FROM Orario1 O INNER JOIN capocantiere C ON O.CapoCantiere=C.Matricola
                                GROUP BY O.Orario
				              );
	INSERT INTO  O2 (SELECT COUNT(*) AS NLav, str_to_date(left(O.Orario,5),"%H:%i") AS ini,
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin
							   FROM Orario2 O
                               GROUP BY O.Orario
				              );
	IF hold<hnew THEN
		SET TS=hold;
		ciclo: LOOP
			SET hold=TS;
			SET TS=ADDTIME(TS,'1:00:00');
			IF(hnew=hold) THEN
				LEAVE ciclo;
			END IF;
			IF (SELECT SUM(O.NLav) + 1
				FROM O2 O
				WHERE O.ini<=hold AND O.fin>=TS
				)
				>
				(SELECT  SUM(O.ML) 
				FROM O1 O
				WHERE O.ini<=hold AND O.fin>=TS
				)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Orario non modificabile';
			END IF;
        END LOOP ciclo;
	END IF;
    IF lnew<lold THEN
		SET TS=lnew;
			ciclo1: LOOP
			SET lnew=TS;
			SET TS=ADDTIME(TS,'1:00:00');
			IF(lold=lnew) THEN
				LEAVE ciclo1;
			END IF;
			IF (SELECT SUM(O.NLav)+1
				FROM O2 O
				WHERE O.ini<=lnew AND O.fin>=TS
				)
				>
				(SELECT SUM(O.ML)
				 FROM O1 O
				WHERE O.ini<=lnew AND O.fin>=TS
				)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Orario non modificabile';
			END IF;
        END LOOP ciclo1;
	END IF;
	SET SQL_SAFE_UPDATES=0;
        DELETE 
        FROM O1;
        DELETE 
        FROM O2;
	 SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS ContaLavoratori3;
DELIMITER $$
CREATE TRIGGER ContaLavoratori3
BEFORE INSERT ON Orario2
FOR EACH ROW
BEGIN
	DECLARE TS TIME;
    DECLARE l TIME;
    DECLARE h TIME;
    SET h=(SELECT str_to_date(right(NEW.Orario,5),"%H:%i"));
    SET l=(SELECT str_to_date(left(NEW.Orario,5),"%H:%i"));
    INSERT INTO  O1  (SELECT str_to_date(left(O.Orario,5),"%H:%i") AS ini, 
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin, SUM(C.MaxLavoratori)AS ML
						FROM Orario1 O INNER JOIN capocantiere C ON O.CapoCantiere=C.Matricola
						GROUP BY  O.Orario
					);
	INSERT INTO O2 (SELECT COUNT(*) AS NLav, str_to_date(left(O.Orario,5),"%H:%i") AS ini,
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin
							   FROM Orario2 O
                               GROUP BY O.Orario
				              );
	SET TS=l;
	ciclo: LOOP
		SET l=TS;
		SET TS=ADDTIME(TS,'1:00:00');
		IF(l=h) THEN
			LEAVE ciclo;
		END IF;
		IF (SELECT SUM(O.NLav) + 1
			FROM O2 O
			WHERE O.ini<=l AND O.fin>=TS
			)
			>
		   (SELECT  SUM(O.ML) 
			FROM O1 O
			WHERE O.ini<=l AND O.fin>=TS
			)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Troppi Operai per i Capi Cantiere al lavoro';
			END IF;
        END LOOP ciclo;
	SET SQL_SAFE_UPDATES=0;
        DELETE 
        FROM O1;
        DELETE 
        FROM O2;
	 SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ContaLavoratori4;
DELIMITER $$
CREATE TRIGGER ContaLavoratori4
BEFORE DELETE ON Orario1
FOR EACH ROW
BEGIN
	DECLARE TS TIME;
	DECLARE ML INTEGER;
    DECLARE l TIMESTAMP;
    DECLARE h TIMESTAMP;
    SET h=(SELECT str_to_date(right(OLD.Orario,5),"%H:%i"));
    SET l=(SELECT str_to_date(left(OLD.Orario,5),"%H:%i"));
    SET ML=(SELECT C.MaxLavoratori
			FROM Capocantiere C
            WHERE OLD.CapoCantiere = C.Matricola
            );
    INSERT INTO O1 (SELECT str_to_date(left(O.Orario,5),"%H:%i") AS ini, 
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin, SUM(C.MaxLavoratori)AS ML
								FROM Orario1 O INNER JOIN capocantiere C ON O.CapoCantiere=C.Matricola
                                GROUP BY O.Orario
				              );
	INSERT INTO O2 (SELECT COUNT(*) AS NLav, str_to_date(left(O.Orario,5),"%H:%i") AS ini,
									  str_to_date(right(O.Orario,5),"%H:%i") AS fin
							   FROM Orario2 O
                               GROUP BY O.Orario
				              );
	SET TS=l;
	ciclo: LOOP
		SET l=TS;
		SET TS=ADDTIME(TS,'1:00:00');
		IF(l=h) THEN
			LEAVE ciclo;
		END IF;
		IF (SELECT SUM(O.NLav) 
			FROM O2 O
			WHERE O.ini<=l AND O.fin>=TS
			)
			>
		   (SELECT  SUM(O.ML) - ML
			FROM O1 O
			WHERE O.ini<=l AND O.fin>=TS
			)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT='Troppi operai assegnati senza il Capo Cantiere';
			END IF;
       
	 END LOOP ciclo;
     SET SQL_SAFE_UPDATES=0;
        DELETE 
        FROM O1;
        DELETE 
        FROM O2;
	 SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS InserimentoSpecificoPietra;
DELIMITER $$
CREATE TRIGGER InserimentoSpecificoPietra
BEFORE INSERT ON Pietra
FOR EACH ROW
	BEGIN
		IF EXISTS(SELECT *
				  FROM Intonaco I
                  WHERE I.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Parquet PQ
                  WHERE PQ.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM	Piastrella P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Mattone M
                  WHERE M.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM MaterialeGenerico MG
                  WHERE MG.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
	END $$
DELIMITER ;


DROP TRIGGER IF EXISTS InserimentoSpecificoMattone;
DELIMITER $$
CREATE TRIGGER InserimentoSpecificoMattone
BEFORE INSERT ON Mattone
FOR EACH ROW
	BEGIN
		IF      ( SELECT M.Copertura OR M.Pavimentabile
				  FROM Materiali M 
                  WHERE M.IDLotto=NEW.Lotto
                  )
		THEN
		    SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale non compatibile';
		END IF;
			
		IF EXISTS(SELECT *
				  FROM Intonaco I
                  WHERE I.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Parquet PQ
                  WHERE PQ.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM	Piastrella P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Pietra P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM MaterialeGenerico MG
                  WHERE MG.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS InserimentoSpecificoMaterialeGenerico;
DELIMITER $$
CREATE TRIGGER InserimentoSpecificoMaterialeGenerico
BEFORE INSERT ON MaterialeGenerico
FOR EACH ROW
	BEGIN
		
		IF EXISTS(SELECT *
				  FROM Intonaco I
                  WHERE I.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Parquet PQ
                  WHERE PQ.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM	Piastrella P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Mattone M
                  WHERE M.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Pietra P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS InserimentoSpecificoPiastrella;
DELIMITER $$
CREATE TRIGGER InserimentoSpecificoPiastrella
BEFORE INSERT ON Piastrella
FOR EACH ROW
	BEGIN
		IF  (SELECT M.Portante
			FROM Materiali M
            WHERE M.IDLotto=NEW.Lotto
            )
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale non compatibile';
		END IF;
		IF EXISTS(SELECT *
				  FROM Intonaco I
                  WHERE I.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Parquet PQ
                  WHERE PQ.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM	Pietra P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Mattone M
                  WHERE M.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM MaterialeGenerico MG
                  WHERE MG.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS InserimentoSpecificoIntonaco;
DELIMITER $$
CREATE TRIGGER InserimentoSpecificoIntonaco
BEFORE INSERT ON Intonaco
FOR EACH ROW
	BEGIN
		IF (SELECT M.Portante OR M.Pavimentabile
			FROM Materiali M
            WHERE M.IDLotto = NEW.Lotto
            )
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
			
		IF EXISTS(SELECT *
				  FROM Pietra P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Parquet PQ
                  WHERE PQ.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM	Piastrella P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Mattone M
                  WHERE M.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM MaterialeGenerico MG
                  WHERE MG.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS InserimentoSpecificoParquet;
DELIMITER $$
CREATE TRIGGER InserimentoSpecificoParquet
BEFORE INSERT ON Parquet
FOR EACH ROW
	BEGIN
		IF (SELECT M.Copertura OR M.Portante
			FROM Materiali M
            WHERE M.IDLotto = NEW.Lotto
            )
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
			
		IF EXISTS(SELECT *
				  FROM Intonaco I
                  WHERE I.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Pietra P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM	Piastrella P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Mattone M
                  WHERE M.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
        IF EXISTS(SELECT *
				  FROM Pietra P
                  WHERE P.lotto= NEW.Lotto
			)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Materiale già Presente';
		END IF;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS Inserimento_Igrometro;
DELIMITER $$
CREATE TRIGGER Inserimento_Igrometro
BEFORE INSERT ON Sensore 
FOR EACH ROW
	BEGIN 
		IF NEW.Tipo="Igrometro" THEN
			IF EXISTS (SELECT *
						FROM Sensore S
                        WHERE S.Tipo='Igrometro' AND S.Vano=NEW.Vano
                        )
				THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Sensore non inseribile siccome già presente';
			END IF;
		END IF;
	END $$
    DELIMITER ;
    
DROP TRIGGER IF EXISTS ControlloOrario1;
DELIMITER $$
CREATE TRIGGER ControlloOrario1
BEFORE INSERT ON Orario1
FOR EACH ROW
BEGIN
	IF NOT EXISTS (
					SELECT *
                    FROM Lavora1 L INNER JOIN Lavoro LV ON L.Progetto=LV.Progetto AND L.Stadio=LV.Stadio AND LV.Numero=L.lavoro
                    WHERE NEW.CapoCantiere = L.CapoCantiere AND LV.DataFine IS NULL
				  ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capo Cantiere non assegnato al lavoro';
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ControlloOrario2;
DELIMITER $$
CREATE TRIGGER ControlloOrario2
BEFORE INSERT ON Orario2
FOR EACH ROW
BEGIN
	IF NOT EXISTS (
					SELECT *
                    FROM Lavora2 L INNER JOIN Lavoro LV ON L.Progetto=LV.Progetto AND L.Stadio=LV.Stadio AND LV.Numero=L.lavoro
                    WHERE NEW.Operaio = L.Operaio
						  AND LV.DataFine IS NULL
				  ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Operaio non assegnato al lavoro';
	END IF;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS SvuotaOrario;
DELIMITER $$
CREATE TRIGGER SvuotaOrario
AFTER UPDATE ON Lavoro
FOR EACH ROW
BEGIN
	IF OLD.DataFine IS NULL AND NEW.DataFine IS NOT NULL THEN
    SET SQL_SAFE_UPDATES=0;
		DELETE 
        FROM Orario2;
        DELETE 
        FROM Orario1;
	SET SQL_SAFE_UPDATES=1;
    INSERT INTO O2 VALUES(0,'01:00:00','23:00:00');
	END IF;
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS controllaFattosuI;
DELIMITER $$
CREATE TRIGGER controllaFattosuI
BEFORE INSERT ON FattoSu
FOR EACH ROW
BEGIN
	IF NOT EXISTS (SELECT *
			   FROM Vano V
				WHERE V.CodiceVano=NEW.Vano AND V.Edificio IN  (SELECT A.Edificio 
																 FROM Associato A
																  WHERE NEW.Progetto= A.Progetto )
				)
		THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'Vano e Lavoro non compatibili';
	END IF;
END $$
DELIMITER ;




DROP TRIGGER IF EXISTS controllaFattosuU;
DELIMITER $$
CREATE TRIGGER controllaFattosuU
BEFORE UPDATE ON FattoSu
FOR EACH ROW
BEGIN
	IF NOT EXISTS (SELECT *
			   FROM Vano V
				WHERE V.CodiceVano=NEW.Vano AND V.Edificio IN  (SELECT A.Edificio 
																 FROM Associato A
																  WHERE NEW.Progetto= A.Progetto )
				)
		THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'Vano e Lavoro non compatibili';
	END IF;
END $$
DELIMITER ;
        
        
         















