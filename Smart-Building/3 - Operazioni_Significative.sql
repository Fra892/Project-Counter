DROP TABLE IF EXISTS Aspetto;
CREATE TABLE Aspetto(Soggetto VARCHAR(12), Descrizione VARCHAR(200));
DROP TABLE IF EXISTS ListaLavoratori;
CREATE TABLE ListaLavoratori(Matricola VARCHAR(8), ruolo VARCHAR(13));
DROP TABLE IF EXISTS StatoEdifici;
CREATE TABLE StatoEdifici(E VARCHAR(6),Controlli INTEGER ,PNU INTEGER, PU INTEGER, Priorita INTEGER);

DROP TRIGGER IF EXISTS CostoProgetto;
DELIMITER $$
CREATE TRIGGER CostoProgetto
BEFORE UPDATE ON progetto
FOR EACH ROW
BEGIN
	DECLARE CostoLavori DECIMAL(9,2);
    DECLARE Sconto DECIMAL(9,2);
    DECLARE Giorni INTEGER;
	IF OLD.DataFine IS NULL AND NEW.DataFine IS NOT NULL THEN
		SET CostoLavori= (SELECT SUM(L.Costo)
						  FROM Lavoro L
						  WHERE NEW.CodiceProgetto=L.Progetto
						  );
		SET Sconto = (SELECT SUM(IF(S.DataFine>S.DataFineStimata,(TIMESTAMPDIFF(day, S.DataFineStimata, S.DataFine) +1)-(TIMESTAMPDIFF(week, S.DataFineStimata, S.DataFine) * 2)*R.Paga*23,0))
					  FROM StadioAvanzamento S INNER JOIN Assegnato A ON A.Stadio = S.Fase AND A.Progetto=S.Progetto
							INNER JOIN Responsabile R ON R.Matricola=A.Responsabile
					  WHERE S.Progetto=NEW.CodiceProgetto
					  );
		SET NEW.CostoProgetto=OLD.CostoProgetto+CostoLavori-Sconto;
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS CostoEdificio;
DELIMITER $$
CREATE PROCEDURE CostoEdificio(IN Edificio VARCHAR(8), OUT Costo DECIMAL(10,2))
BEGIN
	SET Costo = (
				 SELECT SUM(P.CostoProgetto)
                 FROM Progetto P
					  INNER JOIN Associato A ON P.CodiceProgetto = A.Progetto
                 WHERE A.Edificio = Edificio
				);
END $$
DELIMITER ;

DROP TABLE IF EXISTS MV_SensoriDiffettosi;
CREATE TABLE MV_SensoriDiffettosi(CodiceSensore VARCHAR(2), MisureAlert INTEGER, MisureTotali INTEGER);

DROP EVENT IF EXISTS SensoriDifettosi;
DELIMITER $$
CREATE EVENT SensoriDifettosi
ON SCHEDULE EVERY 1 WEEK
STARTS '2023-01-01 23:50:00'
DO
	BEGIN
			DECLARE S VARCHAR(2);
            DECLARE M INTEGER;
            DECLARE A INTEGER;
			DECLARE Tab CURSOR FOR (
									SELECT D.Sensore, D.NMisure, COUNT(*) AS NAlert
									FROM (
										  SELECT D1.Sensore, COUNT(*) AS NMisure
                                          FROM Dati D1
                                          GROUP BY D1.Sensore
										 ) AS D
										 INNER JOIN Alert ON D.Sensore = A.Sensore
									GROUP BY D.Sensore, D.NMisure
							       );
			DECLARE CONTINUE HANDLER 
			FOR NOT FOUND
			SET @finito = 1;
            SET @finito = 0;
			OPEN Tab;
            TRUNCATE TABLE MV_SensoriDifettosi;
			inser:LOOP
				FETCH Tab INTO S,M,A;
				IF @finito=1 THEN
					LEAVE inser;
				END IF;
				IF A >= 2000
                THEN
                    INSERT INTO MV_SensoriDiffettosi VALUES(S,M,A);
				END IF;
			END LOOP inser;
			CLOSE Tab;
            TRUNCATE Alert;
            TRUNCATE Dati;
	END $$
    DELIMITER ;
    
    DROP PROCEDURE IF EXISTS SpesaMateriali;
    DELIMITER $$
    CREATE PROCEDURE SpesaMateriali(OUT Spesa DECIMAL(9,2))
    BEGIN
		SET Spesa = (SELECT SUM(M.QuantitaAcquistata*M.Costo)
					FROM  Materiali M 
					WHERE YEAR(M.DataAcquisto) = YEAR(CURRENT_DATE)
                    );
	END $$
    DELIMITER ;
    
    DROP PROCEDURE IF EXISTS AspettoVano;
    DELIMITER $$
    CREATE PROCEDURE AspettoVano (IN V VARCHAR(8))
    BEGIN
		 DECLARE T VARCHAR (100);
		 DECLARE Pavimento VARCHAR(200);
         DECLARE Parete VARCHAR(200);
		 DECLARE L VARCHAR(8);
		 DECLARE P CURSOR FOR(
							  SELECT M.IDLotto
							  FROM FattoSu F INNER JOIN Lavoro L ON L.Progetto=F.Progetto AND L.Stadio = F.Stadio AND L.Numero = F.Lavoro
								   INNER JOIN Materiali M ON M.Progetto=L.Progetto AND M.Stadio=L.Stadio AND M.Lavoro=L.Numero
							  WHERE L.DataFine IS NOT NULL AND F.Vano=V AND M.Pavimentabile = TRUE AND L.DataFine >= ALL(SELECT L1.DataFine
																														 FROM FattoSu F1 INNER JOIN Lavoro L1 ON L1.Progetto=F1.Progetto AND L1.Stadio = F1.Stadio AND L1.Numero = F1.Lavoro
																														 INNER JOIN Materiali M1 ON M1.Progetto=L1.Progetto AND M1.Stadio=L1.Stadio AND M1.Lavoro=L1.Numero
																														 WHERE L1.DataFine IS NOT NULL AND F1.Vano=V AND M1.Pavimentabile = TRUE
																														)
							);
		 DECLARE  C CURSOR FOR (
							    SELECT M.IDLotto
							    FROM FattoSu F INNER JOIN Lavoro L ON L.Progetto=F.Progetto AND L.Stadio = F.Stadio AND L.Numero = F.Lavoro
								     INNER JOIN Materiali M ON M.Progetto=L.Progetto AND M.Stadio=L.Stadio AND M.Lavoro=L.Numero
							    WHERE L.DataFine IS NOT NULL AND F.Vano=V AND M.Copertura = TRUE AND L.DataFine >= ALL(SELECT L1.DataFine
																														   FROM FattoSu F1 INNER JOIN Lavoro L1 ON L1.Progetto=F1.Progetto AND L1.Stadio = F1.Stadio AND L1.Numero = F1.Lavoro
																																INNER JOIN Materiali M1 ON M1.Progetto=L1.Progetto AND M1.Stadio=L1.Stadio AND M1.Lavoro=L1.Numero
																														   WHERE L1.DataFine IS NOT NULL AND F1.Vano=V AND M1.Copertura = TRUE
																														  )
							);
         DECLARE CONTINUE HANDLER FOR NOT FOUND
         SET  @finito=1;
         SET @finito = 0;
         OPEN P;
		 SP:LOOP
			    FETCH P INTO L;
                IF @finito=1 THEN
					LEAVE SP;
				END IF;
                IF EXISTS (SELECT *
						   FROM Pietra
                           WHERE Lotto = L
                           )
				THEN
                    SET Pavimento='Pietra - ';
                    SET T=(SELECT Tipo
							FROM Pietra 
                            WHERE Lotto = L
                            );
                    SET Pavimento=CONCAT(Pavimento,T);
				END IF;
				IF EXISTS (SELECT *
							   FROM Piastrella
							   WHERE Lotto = L
                              )
				THEN
                    SET Pavimento='Piastrella - ';
                    SET T=(SELECT Fantasia
							FROM Piastrella
                            WHERE Lotto=L
                            );
                    SET Pavimento=CONCAT(Pavimento,T);
				END IF;
				IF EXISTS (SELECT *
						       FROM Parquet
                               WHERE Lotto = L
                              )
				THEN
                    SET Pavimento='Parquet - ';
                    SET T=(SELECT Tipo
							FROM Parquet
                            WHERE Lotto=L
                            );
                    SET Pavimento=CONCAT(Pavimento,T);
				END IF;
			    IF EXISTS (SELECT *
						      FROM MaterialeGenerico
                              WHERE Lotto = L
                             )
				THEN
                    SET Pavimento='MaterialeGenerico - ';
                    SET T=(SELECT Descrizione
							FROM MaterialeGenerico
                            WHERE Lotto=L
                            );
                    SET Pavimento=CONCAT(Pavimento,T);
				END IF;
            INSERT INTO Aspetto VALUES('Pavimento', Pavimento);
		 END LOOP SP;
		 CLOSE P;
		 SET @finito=0;
		 OPEN C;
		 SC:LOOP
				FETCH C INTO L;
                IF @finito=1 THEN
					LEAVE SC;
				END IF;
                IF EXISTS (SELECT *
						   FROM Pietra
                           WHERE Lotto = L
                           )
				THEN
                    SET Parete='Pietra - ';
                    SET T=(SELECT Tipo
							FROM Pietra 
                            WHERE Lotto=L
                            );
                    SET Parete=CONCAT(Parete,T);
				END IF;
				IF EXISTS (SELECT *
						   FROM Piastrella
						   WHERE Lotto = L
						  )
				THEN
                    SET Parete='Piastrella - ';
                    SET T=(SELECT Fantasia
							FROM Piastrella
                            WHERE Lotto=L
                            );
                    SET Parete=CONCAT(Parete,T);
				END IF;
				IF EXISTS (SELECT *
						   FROM Intonaco
						   WHERE Lotto = L
						   )
				THEN
                    SET Parete='Intonaco - ';
                    SET T=(SELECT Colore
							FROM Intonaco
                            WHERE Lotto=L
                            );
                    SET Parete=CONCAT(Parete,T);
			   END IF;
			   IF EXISTS (SELECT *
						  FROM MaterialeGenerico
						  WHERE Lotto = L
						 )
				THEN
                    SET Parete='Materiale Generico - ';
                    SET T=(SELECT Descrizione
							FROM MaterialeGenerico
                            WHERE Lotto=L
                            );
                    SET Parete=CONCAT(Parete,T);
				END IF;
                INSERT INTO Aspetto VALUES ("Parete",Parete);
			END LOOP SC;
		 CLOSE C;
		 SELECT *
         FROM Aspetto;
         SET SQL_SAFE_UPDATES=0;
         DELETE 
         FROM Aspetto;
         SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;               

DROP PROCEDURE IF EXISTS NumeroSensori;
DELIMITER $$
CREATE PROCEDURE NumeroSensori (IN TipoSensore VARCHAR(100), IN Edificio VARCHAR(6), OUT NSensori INTEGER)
BEGIN
    SET NSensori = (SELECT COUNT(*)
					FROM Sensore S
						 INNER JOIN Vano V ON S.Vano = V.CodiceVano
						 INNER JOIN Edificio E ON V.Edificio = E.CodiceEdificio
					WHERE S.Tipo = TipoSensore
					AND E.CodiceEdificio = Edificio
				   );
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS ClassificaAree;
DELIMITER $$
CREATE PROCEDURE ClassificaAree (IN TipoCalamita VARCHAR(100))
BEGIN
	WITH UltimeXAree AS (
						 SELECT *
                         FROM PericoliAmbientali P
                         WHERE P.Tipo=TipoCalamita
                               AND P.Data >= ALL (
												  SELECT P1.Data
												  FROM PericoliAmbientali P1
												  WHERE P1.Tipo=TipoCalamita
													    AND P1.Area = P.Area
											     )
				        )
	SELECT Area, Coefficiente, DENSE_RANK() OVER (
                                                 ORDER BY Coefficiente DESC
												) AS Posizione
    FROM UltimeXAree;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS ListaLavoratori;
DELIMITER $$
CREATE PROCEDURE ListaLavoratori(IN IDP VARCHAR(6))
BEGIN 
	DECLARE M VARCHAR(8);
	DECLARE R CURSOR FOR (SELECT DISTINCT(A.Responsabile)
						  FROM Assegnato A
                          WHERE A.Progetto=IDP
                          );
	DECLARE C_C CURSOR FOR(SELECT  DISTINCT(L.CapoCantiere)
							FROM Lavora1 L
                            WHERE L.Progetto=IDP
							);
	DECLARE O CURSOR FOR (SELECT DISTINCT(L.Operaio)
						  FROM Lavora2 L
						  WHERE L.Progetto=IDP
                          );
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
    SET @finito=1;
    SET @finito = 0;
    OPEN R;
    SR:LOOP
		FETCH R INTO M;
		IF @finito=1  THEN
			LEAVE SR;
		END IF;
        INSERT INTO ListaLavoratori VALUES(M,'Responsabile');
	END LOOP SR;
    CLOSE R;
    SET @finito=0;
    OPEN C_C;
     SC:LOOP
		FETCH C_C INTO M;
		IF @finito=1  THEN
			LEAVE SC;
		END IF;
        INSERT INTO ListaLavoratori VALUES(M,'Capo Cantiere');
	END LOOP SC;
    CLOSE C_C;
    SET @finito=0;
    OPEN O;
     SO:LOOP
		FETCH O INTO M;
		IF @finito=1  THEN
			LEAVE SO;
		END IF;
        INSERT INTO ListaLavoratori VALUES(M,'Operaio');
	END LOOP SO;
    CLOSE O;
    SELECT *
    FROM ListaLavoratori;
	SET SQL_SAFE_UPDATES=0;
	DELETE 
	FROM ListaLavoratori;
	SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;

DROP TABLE IF EXISTS MV_StoricoEdificio;
CREATE TABLE MV_StoricoEdificio(
Data TIMESTAMP NOT NULL,
Edificio VARCHAR(6) NOT NULL,
Vano VARCHAR(8),
Problema VARCHAR(100) NOT NULL,
Intensita INTEGER NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS StoricoCalamita;
DELIMITER $$
CREATE TRIGGER StoricoCalamita
AFTER INSERT ON calamitapassate
FOR EACH ROW
BEGIN
	DECLARE E VARCHAR(6);
    DECLARE Descrizione VARCHAR(100);
    DECLARE I INTEGER;
    DECLARE Cur CURSOR FOR (SELECT E.CodiceEdificio
							FROM Edificio E
							WHERE E.Area=NEW.Area
                            );
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET @finito=1;
    SET @finito = 0;
	OPEN Cur;
    scan:LOOP
		FETCH Cur INTO E;
        IF @finito=1 THEN
			LEAVE scan;
		END IF;
        SET Descrizione=CONCAT("Calamita - ",NEW.Tipo);
        IF NEW.Intensita <4 THEN 
			SET I=0;
		END IF;
        IF NEW.Intensita BETWEEN 4 AND 7 THEN
			SET I=1;
		END IF;
        IF NEW.Intensita >7 THEN
			SET I=2;
		END IF;
        INSERT INTO Mv_StoricoEdificio VALUES(NEW.Data,E,NULL,Descrizione,I);
	END LOOP scan;
    CLOSE Cur;
	SET @finito = 0;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS StoricoImpianti;
DELIMITER $$
CREATE TRIGGER StoricoImpianti
AFTER INSERT ON Alert
FOR EACH ROW
BEGIN
	DECLARE T VARCHAR(100);
    DECLARE I INTEGER;
    DECLARE V VARCHAR(8);
    DECLARE E VARCHAR(6);
    SET V = NEW.Vano;
	SET E=(SELECT V.Edificio
		   FROM Vano V
           WHERE V.CodiceVano = V
           );
    SET T =(SELECT S.Tipo
			FROM Sensore S
			WHERE NEW.Sensore = S.CodiceSensore AND S.Vano = NEW.Vano
            );
	IF T="Barometro" THEN
		IF NEW.Valore < 30 THEN
			SET I=0;
		END IF;
        IF NEW.Valore BETWEEN 30 AND 50 THEN
			SET I=1;
		END IF;
		IF NEW.Valore > 50 THEN
			SET I=2;
		END IF;
        SET T= "Impianto - pressione nelle tubature";
        INSERT INTO MV_StoricoEdificio VALUES(NEW.Data,E,V,T,I);
	END IF;
    IF T="Termostato" THEN
		IF NEW.Valore < 36 THEN
			SET I=0;
		END IF;
        IF NEW.Valore BETWEEN 36 AND 66 THEN
			SET I=1;
		END IF;
		IF NEW.Valore > 66 THEN
			SET I=2;
		END IF;
        SET T= "Impianto - alte temperature probabile incendio, esplsione o danneggiamento impianto";
        INSERT INTO MV_StoricoEdificio VALUES(NEW.Data,E,V,T,I);
	END IF;
END $$
DELIMITER ;

DROP EVENT IF EXISTS StoricoSettimanale;
DELIMITER $$
CREATE EVENT StoricoSettimanale
ON SCHEDULE EVERY 1 WEEK
STARTS '2023-01-01 23:30:00' 
DO 
	BEGIN 
		DECLARE Descrizione VARCHAR(100);
        DECLARE Intensita INTEGER;
        DECLARE Val FLOAT;
        DECLARE V VARCHAR(8);
		DECLARE Spazio FLOAT;
		DECLARE E VARCHAR(6);
        DECLARE Acc FLOAT;
        DECLARE Vel FLOAT;
        DECLARE Cur3 CURSOR FOR (SELECT V.CodiceVano , V.Edificio, D.Valore
								FROM Dati D INNER JOIN Sensore  S ON D.Sensore=S.CodiceSensore INNER JOIN Vano V ON S.Vano=V.CodiceVano
                                WHERE S.Tipo="Fessurimetro" AND NOT EXISTS (SELECT *
																			FROM Dati D1 INNER JOIN Sensore  S1 ON D1.Sensore=S1.CodiceSensore
                                                                            WHERE S1.CodiceSensore=S.CodiceSensore AND S.Vano = S1.Vano AND  D1.Data>D.Data
                                                                            )
                                );
		DECLARE Cur2 CURSOR FOR (SELECT V.CodiceVano , V.Edificio, D.Valore
								FROM Dati D INNER JOIN Sensore  S ON D.Sensore=S.CodiceSensore INNER JOIN Vano V ON S.Vano=V.CodiceVano
                                WHERE S.Tipo="Igrometro" AND NOT EXISTS (SELECT *
																			FROM Dati D1 INNER JOIN Sensore  S1 ON D1.Sensore=S1.CodiceSensore
                                                                            WHERE S1.CodiceSensore=S.CodiceSensore AND S.Vano = S1.Vano AND  D1.Data>D.Data
                                                                            )
                                );
		DECLARE Cur CURSOR FOR (SELECT D.Edificio,D.Velocita,D2.Accelerazione
								FROM (SELECT V.Edificio, D.Valore AS Velocita
									  FROM Dati D INNER JOIN Sensore  S ON D.Sensore=S.CodiceSensore INNER JOIN Vano V ON S.Vano=V.CodiceVano
									  WHERE S.Tipo = "Velocimetro" AND D.Data<= ALL(SELECT MIN(D1.Data)
																					FROM  Dati D1 INNER JOIN Sensore  S1 ON D1.Sensore=S1.CodiceSensore INNER JOIN Vano V1 ON S1.Vano=V1.CodiceVano
																					WHERE S1.Tipo = 'Velocimetro' AND V.Edificio = V1.Edificio
																				 )
									   GROUP BY V.Edificio
									) AS D NATURAL JOIN 
                                     ( SELECT V.Edificio, MAX(D.Valore) AS Accelerazione
									   FROM Dati D INNER JOIN Sensore  S ON D.Sensore=S.CodiceSensore INNER JOIN Vano V ON S.Vano=V.CodiceVano
									   WHERE V.Piano <= ALL( SELECT V1.Piano
															 FROM Vano V1 
															 WHERE V.Edificio = V1.Edificio
															)
									        AND S.Tipo = "Accelerometro"
									   GROUP BY V.Edificio
								) AS D2
                                );
		DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET @finito=1;
		SET @finito = 0;
		OPEN Cur;
        
        scan:LOOP
			FETCH Cur INTO E,Vel,Acc;
            IF @finito = 1 THEN
				LEAVE scan;
			END IF;
            SET Spazio=Vel*604800 + (Acc*(604800*604800))/2;
            IF Spazio < 0.005 THEN
				SET Intensita=0;
			END IF;
            IF Spazio BETWEEN 0.005 AND 0.2 THEN
				SET  Intensita=1;
			END IF;
            IF Spazio >0.2 THEN
				SET Intensita=2;
			END IF;
            SET Descrizione='Terreno - Stato Cedimento Edificio';
            INSERT INTO MV_StoricoEdificio VALUES (CURRENT_TIMESTAMP,E,NULL,Descrizione,Intensita);
		END LOOP scan;
        CLOSE Cur;
        SET @finito=0;
        OPEN Cur2;
        scan2:LOOP
			FETCH Cur2 INTO V,E,Val;
            IF @finito=1 THEN
				LEAVE scan2;
			END IF;
            IF Val < 55 THEN
				SET Intensita=0;
			END IF;
            IF Val BETWEEN 55 AND 65 THEN
				SET  Intensita=1;
			END IF;
            IF Val >65 THEN
				SET Intensita=2;
			END IF;
            SET Descrizione = 'StrutturaleU - Livello Umidità';
            INSERT INTO MV_StoricoEdificio VALUES (CURRENT_TIMESTAMP, E , V, Descrizione ,Intensita);
		END LOOP scan2;
        CLOSE Cur2;
        SET @finito=0;
        OPEN Cur3;
        scan3:LOOP
			FETCH Cur3 INTO V,E,Val;
            IF @finito=1 THEN
				LEAVE scan3;
			END IF;
			IF Val < 1 THEN
				SET Intensita=0;
			END IF;
            IF Val BETWEEN 1  AND 5 THEN
				SET  Intensita=1;
			END IF;
            IF Val >5 THEN
				SET Intensita=2;
			END IF;
            SET Descrizione = 'StrutturaleC - Gravita Crepa';
            INSERT INTO MV_StoricoEdificio VALUES (CURRENT_TIMESTAMP,E,V,Descrizione,Intensita);
		END LOOP scan3;
        CLOSE Cur3;
	END $$
DELIMITER ;
    
    
DROP PROCEDURE IF EXISTS StatoEdifici;
DELIMITER $$
CREATE PROCEDURE StatoEdifici()
BEGIN
	DECLARE E VARCHAR(6);
    DECLARE C INTEGER;
    DECLARE P_N_U INTEGER;
    DECLARE P_U INTEGER;
	DECLARE Cur  CURSOR FOR (SELECT E.CodiceEdificio
							 FROM Edificio E
                             );
	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET @finito=1;
    SET @finito = 0;
    OPEN Cur;
    scan:LOOP
		FETCH Cur INTO E;
        IF @finito=1 THEN
			LEAVE scan;
		END IF;
        SET P_N_U = (SELECT COUNT(*)
				    FROM MV_StoricoEdificio M
                    WHERE M.Edificio = E AND M.Intensita=1
				   );
		SET P_U =  (SELECT COUNT(*)
				   FROM MV_StoricoEdificio M
                   WHERE M.Edificio = E AND M.Intensita=2
                   );
		SET C = (SELECT COUNT(*)
				 FROM MV_StoricoEdificio M
				 WHERE M.Edificio = E AND M.Intensita=0
                 );
		INSERT INTO StatoEdifici VALUES (E,C,P_N_U,P_U,P_N_U + (P_U*2));
	END LOOP scan;
    CLOSE Cur;
    SELECT *
    FROM StatoEdifici;
	SET SQL_SAFE_UPDATES=0;
	DELETE 
    FROM StatoEdifici;
	SET SQL_SAFE_UPDATES=1;
END $$