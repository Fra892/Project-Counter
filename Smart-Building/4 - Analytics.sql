DROP TABLE IF EXISTS result_set;
CREATE TABLE result_set(sezione VARCHAR(100),spesa FLOAT, Parte_Danneggiata VARCHAR(8), Data_Scadenza DATE,Max_Sollecitazioni FLOAT, Probabilita FLOAT,Soluzione VARCHAR(100));
DROP TABLE IF EXISTS SD;
CREATE TABLE SD(Data TIMESTAMP,Edificio VARCHAR(6),Vano VARCHAR(8),Problema VARCHAR(100),Intensita INTEGER);

DROP PROCEDURE IF EXISTS ConsigliDiIntervento;
DELIMITER $$
CREATE PROCEDURE ConsigliDiIntervento(IN E VARCHAR(6))
BEGIN
    DECLARE COUNTER INTEGER DEFAULT 0;
    DECLARE G INTEGER;
    DECLARE H TIMESTAMP;
    DECLARE a INTEGER DEFAULT 0;
	DECLARE S FLOAT;
    DECLARE PD VARCHAR (8);
    DECLARE T DATE;
    DECLARE MS1 FLOAT;
    DECLARE MS2 FLOAT;
    DECLARE PR1 FLOAT;
    DECLARE PR2 FLOAT;
    DECLARE PR3 FLOAT;
	DECLARE D VARCHAR(100);
    DECLARE DT TIMESTAMP;
    DECLARE DT2 TIMESTAMP;
    DECLARE I2 INTEGER;
    DECLARE V2 VARCHAR(8) ;
    DECLARE I INTEGER;
    DECLARE D2  VARCHAR(100);
	DECLARE Cur CURSOR FOR (SELECT M.Data,M.Problema,M.Intensita,M.Vano 
							FROM MV_StoricoEdificio M
                            WHERE M.Edificio = E
                            );
	DECLARE Cur2 CURSOR FOR (SELECT M.Data,M.Intensita,M.Problema,M.Vano
							FROM MV_StoricoEdificio M
                            WHERE M.Edificio = E
                            ORDER BY M.Data 
                            );
	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET @finito = 1;
    SET @finito = 0;
    OPEN Cur;
    scan:LOOP
		FETCH Cur INTO DT,D,I,PD;
        IF @finito = 1 THEN
			LEAVE scan;
		END IF;
        IF left(D,1) = 'C' THEN
			SET S=(	SELECT IF(I=0,0,IF(I=1,AVG(C)*0.45,AVG(C)*0.75))
					FROM(SELECT SUM(L.Costo) AS C
						 FROM Lavoro L 
						 WHERE left(L.Descrizione,1) <> 'D'
						 GROUP BY L.Progetto
                         ) AS D
					);
			SET PR1 =(SELECT IF(SUM(E.Intensita)=NULL,0,SUM(E.Intensita))
					 FROM MV_StoricoEdificio E
                     WHERE E.Edificio = E AND left(E.Problema,12) = 'StrutturaleC' AND E.Data<DT);
			IF PR1 IS NULL THEN
				SET PR1=0;
			END IF;
			SET PR2=(SELECT C.Intensita
						  FROM CalamitaPassate C
                          WHERE C.Data=DT AND C.Area = (SELECT E.Area
														FROM Edificio E 
                                                        WHERE E.CodiceEdificio= E
                                                        )
					 );
                     
			IF PR2 IS NULL THEN
				SET PR2=0;
			END IF;
                                                        
						
			SET PR3=(SELECT DATEDIFF(DT,E1.Data)
					 FROM MV_StoricoEdificio E1
					 WHERE left(E1.Problema,1) = 'S' AND E1.Edificio =E AND E1.Data=(SELECT MAX(E2.Data)
																						FROM MV_StoricoEdificio E2
																						WHERE left(E2.Problema,1) = 'S' AND E2.Edificio = E AND E2.Data<=DT
																					)
					);
			IF PR3 IS NULL THEN
				SET PR3 =1;
			END IF;
			INSERT INTO result_set VALUES('Calamita',S,'generale',NULL,NULL,(PR1+PR2)/PR3,IF(I=0,'Controllo richiesti per integrita della struttura',IF(I=1,'Rinforzi richiesti su pareti portanti e fondamenta','Ricostruzioni di pareti portanti richiesti, fondamenta e impianti')));
		END IF;
        IF left(D,1) = 'I' THEN
			SET S = (SELECT AVG(L.Costo)
					 FROM Lavoro L
                     WHERE left(L.Descrizione,1) = 'I' 
                     );
			IF left(D,12) = 'Impianto - p' THEN
				INSERT INTO result_set VALUES('Impianti',S,PD,NULL,NULL,NULL,IF(I=0,'Controllo Pressione e funzionamento tubature',IF(I=1,'Riparazione delle tubatura in vista di possibili ostruzioni','rifare impianto per imminente esplosione')));
			END IF;
            IF left(D,12) = 'Impianto - a' THEN
				INSERT INTO result_set VALUES('Impianti',S,PD,NULL,NULL,NULL,IF(I=0,'Controllo funzionamento impianto',IF(I=1,'Riparazione dei gasdotti e boiler','rifare impianto di riscaldamento')));
			END IF;
        END IF;
        IF left(D,1) = 'T' THEN
			SET S = (SELECT  AVG(L.Costo)
					 FROM Lavoro L 
                     WHERE left(L.Descrizione,1)='F'
                     );
			OPEN Cur2;
			scan2:LOOP
				FETCH Cur2 INTO DT2,I2,D2,V2;
                IF H=DT THEN
					LEAVE scan2;
				END IF;
                IF left(D2,1) = 'T' THEN
                IF COUNTER > 0  THEN
				 SET a = a + ROUND(((I2-G)/(DATEDIFF(DT2,H))));
				END IF;
                SET H=DT2;
                SET G=I;
                SET COUNTER= COUNTER+1;
                END IF;
			END LOOP scan2;
            CLOSE Cur2;
            SET T= DT2+INTERVAL 2 MONTH - INTERVAL a DAY;
            INSERT INTO result_set VALUES('Terreno',S,'Generale',T,NULL,NULL,IF(I=0,'Controllo generale sul terreno',IF(I=1,'Rinforzi sulle fondamenta','ricostruzioni fondamenta edificio')));
        END IF;
        IF left(D,1) = 'S' THEN 
			SET S = (SELECT AVG(L.Costo)
					 FROM Lavoro L
                     WHERE left(L.Descrizione,1) = 'S' 
                     );
			SET MS1= (SELECT SUM(E.Intensita)
					 FROM MV_StoricoEdificio E
                     WHERE E.Edificio = E AND left(E.Problema,12) = 'StrutturaleC' AND E.Data<DT
                     );
			IF MS1 IS NULL THEN
				SET MS1=0;
			END IF;
			SET MS2=(SELECT DATEDIFF(DT,E.Data)
					  FROM MV_StoricoEdificio E 
                      WHERE E.Edificio = E AND left(E.Problema,12) = 'C'  AND E.Data=(SELECT MAX(E2.Data)
																						 FROM MV_storicoEdificio E2
																						 WHERE E2.Edificio = E AND left(E2.Problema,12) = 'C' AND E2.Data<DT
                                                                                         )
					                                                        );
			IF MS2 IS NULL THEN
				SET MS2=10;
			END IF;
			OPEN Cur2;
            SET a=0;
            SET COUNTER = 0;
			scan3:LOOP
				FETCH Cur2 INTO DT2,I2,D2,V2;
                IF H=DT THEN
					LEAVE scan3;
				END IF;
                IF left(D2,1) = 'S' AND  V2 = PD THEN
                IF COUNTER > 0  THEN
				 SET a = a + ROUND(((I2-G)/(DATEDIFF(DT2,H))));
				END IF;
                SET H=DT2;
                SET G=I;
                SET COUNTER= COUNTER+1;
                END IF;
			END LOOP scan3;
            CLOSE Cur2;
			SET T= DT2+INTERVAL 2 MONTH - INTERVAL a DAY;
            SET @p = MS1;
            SET @i = MS2;
            SET @d = DT;
            INSERT INTO result_set VALUES('Struttura',S,PD,T,-MS1+0.7*MS2,NULL,IF(I=0,'Controllo generale sul vano',IF(I=1,'Rinforzi sulle pareti del vano','ricostruzione totale vano')));
        END IF;
	END LOOP scan;
    CLOSE cur;
    SELECT *
    FROM result_set;
    SET SQL_SAFE_UPDATES=0;
	DELETE 
	FROM result_set;
	SET SQL_SAFE_UPDATES=1;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS Stima_Danni;
DELIMITER $$
CREATE PROCEDURE Stima_Danni ( IN E VARCHAR(6) , IN Magnitudo FLOAT)
BEGIN 
	DECLARE P INTEGER;
	DECLARE I INTEGER;
	DECLARE G INTEGER;
	DECLARE V VARCHAR(8);
    DECLARE Cur CURSOR FOR (SELECT  M.Vano,M.Intensita
							FROM MV_StoricoEdificio M
                            WHERE M.Edificio = E AND left(M.Problema,12) = 'StrutturaleC' AND ((Magnitudo>7 AND M.intensita >=1) OR (Magnitudo BETWEEN 7 AND 4 AND M.intensita=2))
                            );
	DECLARE Cur2 CURSOR FOR (SELECT V.CodiceVano
							 FROM Vano V
                             WHERE V.Edificio = E
                             );
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET @finito=1;
	SET @finito = 0;
	IF NOT EXISTS (SELECT *
				   FROM Edificio E
                   WHERE E.CodiceEdificio = E
                   )
		THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'Edificio inesistente';
	END IF;
    IF Magnitudo < 4  THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'stato invariato';
	END IF;
    IF Magnitudo > 10 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Magnitudo non compatibile';
	END IF;
	INSERT INTO SD( SELECT *
					FROM MV_StoricoEdificio M
					WHERE  M.Edificio= E 
                              );
                              
	SET G = IF(Magnitudo>7,2,1);
    SET P = IF (G=2,40,20);
    
	INSERT INTO SD VALUES (CURRENT_TIMESTAMP,E,NULL,'Calamità - Terremoto',G);
    SET SQL_SAFE_UPDATES=0;
    UPDATE SD 
    SET SD.Intensita = IF(SD.Intensita+G>2,2,SD.Intensita+G)
    WHERE SD.Intensita <2 AND left(SD.Problema,12) = 'StrutturaleC';
    SET SQL_SAFE_UPDATES=1;
    OPEN Cur;
    scan:LOOP
		FETCH Cur INTO V,I;
        IF @finito=1 THEN
			LEAVE scan;
		END IF;
        INSERT INTO SD VALUES(CURRENT_TIMESTAMP,E,V,'StrutturaleC - Gravita Crepa',(I+G)-2);
	END LOOP scan;
    CLOSE Cur;
    SET @finito=0;
    OPEN Cur2;
    scan2:LOOP
		FETCH Cur2 INTO V;
        IF @finito = 1 THEN
			LEAVE scan2;
		END IF;
        IF(TRUNCATE(RAND()*100,0) <= P) THEN
			INSERT INTO SD VALUES (CURRENT_TIMESTAMP,E,V,'StrutturaleC - Gravita Crepa',1);
		END IF;
	END LOOP scan2;
    CLOSE Cur2;
    SELECT *
    FROM SD;
    SET SQL_SAFE_UPDATES=0;
	DELETE 
    FROM SD;
    SET SQL_SAFE_UPDATES=1;
END $$
    
    
        
        
        
        
    
    
    
    
	

















