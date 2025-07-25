DROP PROCEDURE IF EXISTS Prova1;
DELIMITER $$
CREATE PROCEDURE Prova1()
BEGIN
		DECLARE Ar VARCHAR(100);
        DECLARE Ti VARCHAR(100);
        DECLARE Ts TIMESTAMP;
        DECLARE Cur CURSOR FOR (
								 SELECT *
                                 FROM LOG_Calamita
							   );
		DECLARE CONTINUE HANDLER 
		FOR NOT FOUND
		SET @finito = 1;
		SET @finito = 0;
		OPEN Cur;
        scan: LOOP
			FETCH Cur INTO Ar, Ti, Ts;
            IF @finito=1 THEN
				LEAVE scan;
			END IF;
            CALL GeneraCalP(Ti,Ar,Ts);
        END LOOP scan;
        CLOSE Cur;
        TRUNCATE LOG_Calamita;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Prova2;
DELIMITER $$
CREATE PROCEDURE Prova2()
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