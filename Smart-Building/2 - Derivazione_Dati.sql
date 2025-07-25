DROP TABLE IF EXISTS LOG_Calamita;
CREATE TABLE LOG_Calamita(
	Area VARCHAR(100) NOT NULL,
    Tipo VARCHAR(100) NOT NULL,
    TS TIMESTAMP NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS IncEsperienza;
DELIMITER $$
CREATE TRIGGER IncEsperienza
AFTER UPDATE ON lavoro
FOR EACH ROW
BEGIN
	IF NEW.DataFine IS NOT NULL AND OLD.DataFine IS NOT NULL THEN
		UPDATE CapoCantiere C
        SET C.Esperienza=C.Esperienza+1
        WHERE C.Matricola IN (SELECT DISTINCT L.CapoCantiere
							  FROM Lavora1 L
                              WHERE L.Stadio=NEW.Stadio AND L.Lavoro=NEW.Numero AND L.Progetto=NEW.Progetto
						); 
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS MaxLavoratoriU;
DELIMITER $$
CREATE TRIGGER MaxLavoratoriU
BEFORE UPDATE ON CapoCantiere
FOR EACH ROW
BEGIN
	IF OLD.Esperienza <> NEW.Esperienza THEN
        SET NEW.MaxLavoratori = round((5 + NEW.Esperienza)/4,0);
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS MaxLavoratoriI;
DELIMITER $$
CREATE TRIGGER MaxLavoratoriI
BEFORE INSERT ON CapoCantiere
FOR EACH ROW
BEGIN
    SET NEW.MaxLavoratori = round((5 + NEW.Esperienza)/4,0);
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS CostoLavoro;
DELIMITER $$
CREATE TRIGGER CostoLavoro
BEFORE UPDATE ON Lavoro
FOR EACH ROW
BEGIN
	DECLARE C_mo DECIMAL(8,2) DEFAULT 0;
    DECLARE Giorni INTEGER DEFAULT 0;
    DECLARE C_ma DECIMAL(8,2) DEFAULT 0;
    
    IF NEW.DataFine IS NOT NULL AND OLD.DataFine IS NULL THEN
		SET Giorni = (TIMESTAMPDIFF(day, OLD.DataInizio, NEW.DataFine) +1)-(TIMESTAMPDIFF(week, OLD.DataInizio, NEW.DataFine) * 2);
		SET C_ma = (SELECT SUM(M.QuantitaAcquistata*M.Costo)
				    FROM Materiali M
				    WHERE M.Progetto=NEW.Progetto AND M.Stadio=NEW.Stadio AND M.Lavoro=NEW.Numero
                   );
		SET C_mo=( SELECT SUM(D.StipendioLav)
				    FROM  (SELECT SUM(O.Paga*(HOUR(str_to_date(right(O2.Orario,5),"%H:%i")-str_to_date(left(O2.Orario,5),"%H:%i"))))*Giorni AS StipendioLav
						   FROM Lavora2 L INNER JOIN Operaio O ON O.Matricola=L.Operaio 
								  INNER JOIN Orario2 O2 ON O2.Operaio=O.Matricola
						   WHERE L.Progetto=NEW.Progetto AND L.Stadio=NEW.Stadio AND L.Lavoro=NEW.Numero
						   GROUP BY O.Matricola
							)AS D
				 );
		
		SET C_mo = C_mo + (SELECT SUM(D.StipendioLav)
				           FROM (SELECT SUM(C.Paga*(HOUR(str_to_date(right(O1.Orario,5),"%H:%i")-str_to_date(left(O1.Orario,5),"%H:%i"))))*Giorni AS StipendioLav
								   FROM Lavora1 L INNER JOIN CapoCantiere C ON C.Matricola=L.CapoCantiere 
									    INNER JOIN Orario1 O1 ON O1.CapoCantiere=C.Matricola
								   WHERE L.Progetto=NEW.Progetto AND L.Stadio=NEW.Stadio AND L.Lavoro=NEW.Numero
								   GROUP BY C.Matricola
								  ) AS D
                           );
		
        SET NEW.Costo=OLD.Costo+C_mo+C_ma;
	END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS GeneraCalP;
DELIMITER $$
CREATE PROCEDURE GeneraCalP( IN Tipo VARCHAR(100), IN Epicentro VARCHAR(100), IN Tempo TIMESTAMP)
BEGIN
	DECLARE A VARCHAR(100);
    DECLARE V FLOAT;
	DECLARE Cur  CURSOR FOR (
							 SELECT E.Area, AVG(D.Valore)
							 FROM (
								   SELECT D1.Vano, D1.Sensore, D1.Valore
								   FROM Dati D1
										INNER JOIN
										Sensore S1 ON D1.Sensore = S1.CodiceSensore
								   WHERE D1.Data BETWEEN Tempo AND ADDTIME(Tempo, '01:00:00')
										 AND S1.Tipo = Tipo
								  ) AS D
								  INNER JOIN Vano V ON V.CodiceVano = D.Vano
								  INNER JOIN Edificio E ON E.CodiceEdificio = V.Edificio
							 GROUP BY E.Area
						    );
	DECLARE CONTINUE HANDLER 
		FOR NOT FOUND
		SET @finito = 1;
    SET @finito = 0;
    OPEN Cur;
    inser:LOOP
		FETCH Cur INTO A,V;
        IF @finito=1 THEN
			LEAVE inser;
		END IF;
        INSERT INTO CalamitaPassate VALUES (CURRENT_DATE,Tipo,A,V,Epicentro);
	END LOOP inser;
	CLOSE Cur;
    END $$
DELIMITER ;

DROP TRIGGER IF EXISTS RiempiLog;
DELIMITER $$
CREATE TRIGGER RiempiLog
BEFORE INSERT ON DATI
FOR EACH ROW
BEGIN
	DECLARE T VARCHAR(100);
	DECLARE A VARCHAR(100);
    DECLARE Prova TIMESTAMP;
    SET Prova = (
				 SELECT MAX(TS)
				 FROM LOG_Calamita
				);
	IF (SELECT S.Calamitoso
		FROM Sensore S
		WHERE NEW.Sensore = S.CodiceSensore AND NEW.Vano = S.Vano ) = TRUE 
        THEN
                SET T = (
						 SELECT S.Tipo
                         FROM Sensore S
                         WHERE S.CodiceSensore = NEW.Sensore AND S.Vano = NEW.Vano
						);
				SET A = (
						 SELECT E.Area
                         FROM Sensore S INNER JOIN Vano V ON S.Vano = V.CodiceVano
							  INNER JOIN Edificio E ON E.CodiceEdificio = V.Edificio
                         WHERE S.Vano = NEW.Vano
							   AND S.CodiceSensore = NEW.Sensore
						);
				IF Prova IS NULL OR (ADDTIME(Prova, '01:00:00')<CURRENT_TIMESTAMP) THEN
					INSERT INTO LOG_Calamita VALUES(A,T,CURRENT_TIMESTAMP);
				END IF;
	END IF;
END $$
DELIMITER ;

DROP EVENT IF EXISTS CheckLogCalamita;
DELIMITER $$
CREATE EVENT CheckLogCalamita
ON SCHEDULE EVERY 1 DAY
STARTS '2023-01-01 23:55:00'
DO
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
    
DROP TRIGGER IF EXISTS CoefficentePericolo;
DELIMITER $$
CREATE TRIGGER CoefficentePericolo
AFTER INSERT ON CalamitaPassate
FOR EACH ROW
BEGIN
    DECLARE Coef FLOAT;
    SET Coef = (
                SELECT AVG(Intensita)
                FROM CalamitaPassate C
                WHERE C.Area = NEW.Area
                      AND C.Tipo = NEW.Tipo
               );
    INSERT INTO PericoliAmbientali VALUES(NEW.Data, NEW.Tipo, NEW.Area, Coef);
END $$
DELIMITER ;
