#Test Operazione Costo Progetto
#Per testare poniamo fine al 2° lavoro del 2° stadio, attivando il trigger CostoLavoro
#Attiverà anche l'incremento dell'esperienza dei Capi Cantiere e, di conseguenza, del loro Max Lavoratori
#Infine aggiorniamo la DataFine del progetto
/*
SELECT *
FROM CapoCantiere C INNER JOIN Lavora1 L ON C.Matricola = L.CapoCantiere
WHERE L.Progetto='666AAA' AND L.Stadio=2 AND L.Lavoro=2;

UPDATE Lavoro
SET DataFine = '2023-12-27'
WHERE Progetto='666AAA' AND Stadio=2 AND Numero=2;

SELECT *
FROM Lavoro
WHERE Progetto='666AAA' AND Stadio=2 AND Numero=2;

SELECT *
FROM CapoCantiere C INNER JOIN Lavora1 L ON C.Matricola = L.CapoCantiere
WHERE L.Progetto='666AAA' AND L.Stadio=2 AND L.Lavoro=2;

UPDATE Progetto
SET DataFine = '2023-12-27'
WHERE CodiceProgetto='666AAA';

SELECT *
FROM Progetto
WHERE CodiceProgetto='666AAA';
*/
#Test Riempimento Calamità Passate e Pericoli Ambientali
#Inseriamo delle misure per simulare un terremoto, ciò porterà la creazione di record in Alert, Calamità Passate e Pericoli Ambientali.
#Usiamo una procedure per simulare l'evento.
/*
INSERT INTO Dati VALUES('A1','AAAB2003',CURRENT_TIMESTAMP,6.2); #Provincia4
INSERT INTO Dati VALUES('A1','AAAB2003',CURRENT_TIMESTAMP + INTERVAL 2 SECOND,6.2); 
INSERT INTO Dati VALUES('A1','AAAB2003',CURRENT_TIMESTAMP + INTERVAL 4 SECOND,6.2);
INSERT INTO Dati VALUES('A1','AAAB2003',CURRENT_TIMESTAMP + INTERVAL 6 SECOND,6.2);

INSERT INTO Dati VALUES('A1','AAAC3002',CURRENT_TIMESTAMP,6.7); #Provincia3
INSERT INTO Dati VALUES('A1','AAAC3002',CURRENT_TIMESTAMP + INTERVAL 2 SECOND,6.7);
INSERT INTO Dati VALUES('A1','AAAC3002',CURRENT_TIMESTAMP + INTERVAL 4 SECOND,6.7);
INSERT INTO Dati VALUES('A1','AAAC3002',CURRENT_TIMESTAMP + INTERVAL 6 SECOND,6.7);

INSERT INTO Dati VALUES('A1','AAAA1003',CURRENT_TIMESTAMP,7);# Provincia1
INSERT INTO Dati VALUES('A1','AAAA1003',CURRENT_TIMESTAMP + INTERVAL 2 SECOND,7);
INSERT INTO Dati VALUES('A1','AAAA1003',CURRENT_TIMESTAMP + INTERVAL 4 SECOND,7);
INSERT INTO Dati VALUES('A1','AAAA1003',CURRENT_TIMESTAMP + INTERVAL 6 SECOND,7);

CALL Prova1();

SELECT *
FROM Alert;

SELECT *
FROM calamitapassate;

SELECT *
FROM pericoliambientali;
*/

#Test Operazione Costo Edificio
#Chiamiamo l'Operazione e diamo in ingresso un Edificio e una variabile dove l'Operazione restituirà il Costo dell'Edificio
/*
CALL CostoEdificio('AAA666', @C);
SELECT @C;
*/

#Test Sensori Diffetosi
#Non la eseguiamo perchè richiede il riempimento di almeno 2000 record nella tabella Alert

#TEST Spesa Materiali
#Chiamiamo l'Operazione e diamo una variabile, l'operazione restituirà in essa la spesa annuale di materiale
/*
CALL SpesaMateriali(@S);
SELECT @S;
*/

#Test Aspetto Vano
#Chiamiamo l'Operazione e diamo un Codice Vano, l'Operazione restituirà una tabella derivata dagli ultimi lavori completati su di esso
/*
CALL AspettoVano('AAAC3002');
*/

#Test Numero Sensori
#Chiamiamo l'Operazione e diamo un Tipo di Sensore, un Edificio e una variabile dove l'Operazione restituirà il Numero di Sensori di Quel Tipo in Quel'Edificio
/*
CALL NumeroSensori('Barometro','AAA444',@N);
SELECT @N;
*/

#Test Classifica Aree
#Chiamiamo l'Operazione e diamo un Tipo di Calamità e l'Operazione restituisce una tabella con una Classifica per Coefficente di Rischio delle Aree
/*
CALL ClassificaAree('Terremoto');
*/

#Test Lista Lavoratori
#Chiamiamo l'Operazione e diamo un Codice Progetto e l'Operazione restituisce una tabella con la Matricola di tutti i Dipendenti che hanno partecipato
/*
CALL ListaLavoratori('666AAA');
*/

#Test Inserimento Storico Edificio Settimanale (Terreno, Fessurimetri, Umidità)
#Chiamiamo una procedure per simulare l'evento settimanale che si occupa dell'inserimento di record in storico edificio
/*
SELECT *
FROM mv_storicoedificio;

CALL Prova2();

SELECT *
FROM mv_storicoedificio;
*/

#Test Stato Edifici
#Chiamiamo l'Operazione e ci restituisce una tabella con il numero di problemi non urgenti e urgenti
/*
CALL StatoEdifici();
*/

#Test Consigli D'Intervento
#Chiamiamo l'Operazione e diamo un Codice Edificio e l'Operazione restituisce una tabella con i lavori suggeriti per riparare i problemi
/*
CALL ConsigliDiIntervento('AAA111');
*/

#Test Stima Danni
#Chiamiamo l'Operazione e diamo un Codice Edificio e un numero che rappresenta il Magnitudo, l'Operazione restituisce una tabella facsimile a Storico Edificio, ma solo per quell'Edificio, con i vecchi problemi
#e nuovi problemi, quest'ultimi sono espansioni di crepe e nuove crepe (tutto in base all'intensità del terremoto)
/*
CALL Stima_Danni('AAA777',8);

SELECT *
FROM mv_storicoedificio
WHERE edificio = 'AAA777';
*/