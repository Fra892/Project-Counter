-- Progettazione Web 
DROP DATABASE if exists vesigna_635489; 
CREATE DATABASE vesigna_635489; 
USE vesigna_635489; 
-- MySQL dump 10.13  Distrib 5.7.28, for Win64 (x86_64)
--
-- Host: localhost    Database: vesigna_635489
-- ------------------------------------------------------
-- Server version	5.7.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aeroporti`
--

DROP TABLE IF EXISTS `aeroporti`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aeroporti` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `codice_iata` varchar(3) NOT NULL,
  `citta` varchar(255) NOT NULL,
  `paese` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codice_iata` (`codice_iata`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporti`
--

LOCK TABLES `aeroporti` WRITE;
/*!40000 ALTER TABLE `aeroporti` DISABLE KEYS */;
INSERT INTO `aeroporti` VALUES (1,'Heathrow Airport','LHR','Londra','Regno Unito'),(2,'Charles de Gaulle Airport','CDG','Parigi','Francia'),(3,'Frankfurt Airport','FRA','Francoforte','Germania'),(4,'Schiphol Airport','AMS','Amsterdam','Paesi Bassi'),(5,'Malpensa Airport','MXP','Milano','Italia'),(6,'Vienna International Airport','VIE','Vienna','Austria'),(7,'Zurich Airport','ZRH','Zurigo','Svizzera'),(8,'Munich Airport','MUC','Monaco di Baviera','Germania'),(9,'Lisbon Airport','LIS','Lisbona','Portogallo'),(10,'Stansted Airport','STN','Londra','Regno Unito'),(11,'Pulkovo Airport','LED','San Pietroburgo','Russia'),(12,'Sheremetyevo Airport','SVO','Mosca','Russia'),(13,'Domodedovo Airport','DME','Mosca','Russia'),(14,'King Khalid Airport','RUH','Riyad','Arabia Saudita'),(15,'Fiumicino Airport','FCO','Roma','Italia'),(16,'Linate Airport','LIN','Milano','Italia'),(17,'Marco Polo Airport','VCE','Venezia','Italia'),(18,'Orio al Serio Airport','BGY','Bergamo','Italia'),(19,'Ciampino Airport','CIA','Roma','Italia'),(20,'Capodichino Airport','NAP','Napoli','Italia'),(21,'Caselle Airport','TRN','Torino','Italia'),(22,'Treviso Airport','TSF','Treviso','Italia'),(23,'Pisa Airport','PSA','Pisa','Italia'),(24,'Tallinn Airport','TLL','Tallinn','Estonia'),(25,'Vilnius Airport','VNO','Vilnius','Lituania');
/*!40000 ALTER TABLE `aeroporti` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messaggi_sistema`
--

DROP TABLE IF EXISTS `messaggi_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messaggi_sistema` (
  `username` varchar(18) NOT NULL,
  `messaggio` varchar(255) NOT NULL,
  KEY `username` (`username`),
  CONSTRAINT `messaggi_sistema_ibfk_1` FOREIGN KEY (`username`) REFERENCES `utenti` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messaggi_sistema`
--

LOCK TABLES `messaggi_sistema` WRITE;
/*!40000 ALTER TABLE `messaggi_sistema` DISABLE KEYS */;
/*!40000 ALTER TABLE `messaggi_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ricerche`
--

DROP TABLE IF EXISTS `ricerche`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ricerche` (
  `id_ricerca` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(18) NOT NULL,
  PRIMARY KEY (`id_ricerca`),
  KEY `username` (`username`),
  CONSTRAINT `ricerche_ibfk_1` FOREIGN KEY (`username`) REFERENCES `utenti` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ricerche`
--

LOCK TABLES `ricerche` WRITE;
/*!40000 ALTER TABLE `ricerche` DISABLE KEYS */;
INSERT INTO `ricerche` VALUES (3,'admin'),(4,'admin'),(5,'admin'),(6,'gianni'),(7,'gianni'),(8,'gianni'),(9,'gianni'),(12,'luigi'),(13,'luigi'),(10,'marco'),(11,'marco');
/*!40000 ALTER TABLE `ricerche` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ricerche_voli`
--

DROP TABLE IF EXISTS `ricerche_voli`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ricerche_voli` (
  `id_ricerca` int(11) NOT NULL,
  `id_volo` int(11) NOT NULL,
  KEY `id_ricerca` (`id_ricerca`),
  KEY `id_volo` (`id_volo`),
  CONSTRAINT `ricerche_voli_ibfk_1` FOREIGN KEY (`id_ricerca`) REFERENCES `ricerche` (`id_ricerca`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ricerche_voli_ibfk_2` FOREIGN KEY (`id_volo`) REFERENCES `voli` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ricerche_voli`
--

LOCK TABLES `ricerche_voli` WRITE;
/*!40000 ALTER TABLE `ricerche_voli` DISABLE KEYS */;
INSERT INTO `ricerche_voli` VALUES (3,16),(3,17),(3,19),(4,27),(4,28),(5,1),(5,21),(5,20),(6,34),(6,35),(6,36),(7,39),(7,40),(7,41),(8,29),(8,19),(9,268),(10,9),(10,10),(11,271),(12,12),(13,40),(13,41);
/*!40000 ALTER TABLE `ricerche_voli` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `utenti`
--

DROP TABLE IF EXISTS `utenti`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `utenti` (
  `username` varchar(18) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `salt` varchar(255) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `utenti`
--

LOCK TABLES `utenti` WRITE;
/*!40000 ALTER TABLE `utenti` DISABLE KEYS */;
INSERT INTO `utenti` VALUES ('admin','$2y$10$tWYRMqa5rKUlm17yQ0la9e0KISBNKk4VOvU3O3HQ9MR8J5KBKRgb2','vYhvCIauSszj6wC8'),('gianni','$2y$10$/2iYuzoRmD/ZOMVS3VpCHei/jRDlrByjGDn87e5GCq2wifAIrO/Fe','Xp5TsqxhjUFuq3vI'),('luigi','$2y$10$f6XDvyC4Iuprw9QVL0AeLeSLt0oIwHfp1bvWvT5xTQPRGmFmN3i.2','3cPzQFTWCAF+xG+r'),('marco','$2y$10$RBaNXIWuAzwbvnA.4hYO/eRntsremvMlRkAKTAX1vkI499BacHLnC','phDDKAYwfv1BlUbG');
/*!40000 ALTER TABLE `utenti` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `voli`
--

DROP TABLE IF EXISTS `voli`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voli` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aeroporto_partenza` int(11) NOT NULL,
  `aeroporto_arrivo` int(11) NOT NULL,
  `data_partenza` datetime NOT NULL,
  `data_arrivo` datetime NOT NULL,
  `codice_volo` varchar(6) NOT NULL,
  `compagnia_aerea` varchar(255) NOT NULL,
  `prezzo` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_codice_compagnia` (`codice_volo`,`compagnia_aerea`),
  KEY `aeroporto_arrivo` (`aeroporto_arrivo`),
  KEY `aeroporto_partenza` (`aeroporto_partenza`),
  CONSTRAINT `voli_ibfk_1` FOREIGN KEY (`aeroporto_arrivo`) REFERENCES `aeroporti` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voli_ibfk_2` FOREIGN KEY (`aeroporto_partenza`) REFERENCES `aeroporti` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=288 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `voli`
--

LOCK TABLES `voli` WRITE;
/*!40000 ALTER TABLE `voli` DISABLE KEYS */;
INSERT INTO `voli` VALUES (1,20,23,'2025-04-15 06:00:00','2025-04-15 06:30:00','110011','Alitalia',35),(2,23,18,'2025-04-15 10:30:00','2025-04-15 11:45:00','001110','Alitalia',43),(3,12,5,'2025-04-15 08:00:00','2025-04-15 19:00:00','220011','Ryanair',390),(4,12,8,'2025-04-15 09:00:00','2025-04-15 15:10:00','758377','Lufthansa',283),(5,12,1,'2025-04-15 11:00:00','2025-04-15 16:00:00','932819','Wizzair',300),(6,16,15,'2025-04-15 09:15:00','2025-04-15 10:10:00','253625','Alitalia',40),(7,16,9,'2025-04-15 16:00:00','2025-04-15 19:10:00','283911','Airfrance',90),(8,8,2,'2025-04-15 11:15:00','2025-04-15 13:20:00','221809','Airfrance',75),(9,5,8,'2025-04-15 07:25:00','2025-04-15 09:15:00','967597','Alitalia',91),(10,8,12,'2025-04-15 15:09:00','2025-04-15 22:14:00','555555','Lufthansa',276),(11,18,5,'2025-04-15 11:17:00','2025-04-15 12:58:00','919191','Alitalia',45),(12,17,4,'2025-04-15 10:00:00','2025-04-15 16:15:00','732723','Alitalia',175),(13,5,17,'2025-04-15 09:17:00','2025-04-15 10:04:00','332326','Alitalia',24),(14,20,7,'2025-04-15 10:17:00','2025-04-15 11:47:00','998877','Alitalia',59),(15,7,25,'2025-04-15 19:21:00','2025-04-15 22:23:00','192899','Emirates',190),(16,20,23,'2025-04-15 16:21:00','2025-04-15 17:23:00','189291','Alitalia',56),(17,23,1,'2025-04-15 19:00:00','2025-04-15 22:24:00','746529','Alitalia',178),(18,1,3,'2025-04-15 22:50:00','2025-04-15 23:56:00','739201','Emirates',98),(19,1,4,'2025-04-15 22:27:00','2025-04-15 23:39:00','293010','Lufthansa',76),(20,6,4,'2025-04-15 15:28:00','2025-04-15 17:27:00','295333','Lufthansa',98),(21,23,6,'2025-04-15 10:27:00','2025-04-15 12:30:00','993452','Alitalia',89),(22,20,4,'2025-04-15 07:29:00','2025-04-15 12:31:00','987653','Emirates',346),(23,20,21,'2025-04-15 08:30:00','2025-04-15 09:33:00','444444','Alitalia',56),(24,21,4,'2025-04-15 13:33:00','2025-04-15 16:32:00','888888','Lufthansa',120),(25,5,12,'2025-04-15 08:00:00','2025-04-15 17:44:00','543216','Emirates',780),(26,22,5,'2025-04-15 14:36:00','2025-04-15 15:15:00','902378','Alitalia',21),(27,20,5,'2025-04-15 06:35:00','2025-04-15 08:39:00','901283','Alitalia',76),(28,5,4,'2025-04-15 13:39:00','2025-04-15 16:39:00','384922','Emirates',270),(29,20,1,'2025-04-15 08:50:00','2025-04-15 11:35:00','029300','Alitalia',99),(30,1,24,'2025-04-15 14:52:00','2025-04-15 17:06:00','009999','Emirates',190),(31,24,4,'2025-04-15 19:02:00','2025-04-15 21:55:00','666677','Ryanair',127),(32,20,10,'2025-04-15 04:52:00','2025-04-15 09:55:00','923456','Ryanair',90),(33,10,4,'2025-04-15 11:57:00','2025-04-15 13:55:00','900222','Airfrance',167),(34,20,19,'2025-04-15 02:05:00','2025-04-15 03:08:00','022433','Alitalia',90),(35,19,8,'2025-04-15 05:02:00','2025-04-15 08:03:00','832988','Lufthansa',121),(36,8,4,'2025-04-15 09:02:00','2025-04-15 10:23:00','777888','Ryanair',90),(37,19,14,'2025-04-15 04:05:00','2025-04-15 08:05:00','966266','Emirates',145),(38,19,13,'2025-04-15 09:05:00','2025-04-15 19:04:00','299999','Ryanair',398),(39,20,17,'2025-04-15 01:10:00','2025-04-15 02:10:00','392991','Alitalia',49),(40,17,3,'2025-04-15 04:11:00','2025-04-15 07:18:00','562100','Ryanair',187),(41,3,4,'2025-04-15 10:11:00','2025-04-15 12:10:00','664420','Ryanair',89),(247,23,20,'2025-04-16 06:30:00','2025-04-16 07:00:00','110013','Airfrance',37),(248,18,23,'2025-04-16 10:15:00','2025-04-16 11:30:00','123458','Wizzair',45),(249,5,12,'2025-04-16 08:30:00','2025-04-16 19:00:00','220014','Ryanair',395),(250,8,12,'2025-04-16 09:15:00','2025-04-16 15:30:00','758380','Lufthansa',285),(251,1,12,'2025-04-16 11:00:00','2025-04-16 16:15:00','932821','Alitalia',310),(252,15,16,'2025-04-16 09:45:00','2025-04-16 10:40:00','253627','Alitalia',42),(253,9,16,'2025-04-16 16:30:00','2025-04-16 19:40:00','283914','Airfrance',95),(254,2,8,'2025-04-16 11:30:00','2025-04-16 13:35:00','221810','Airfrance',78),(255,8,5,'2025-04-16 07:40:00','2025-04-16 09:35:00','967600','Alitalia',93),(256,12,8,'2025-04-16 15:30:00','2025-04-16 22:45:00','555558','Lufthansa',280),(257,5,18,'2025-04-16 11:00:00','2025-04-16 12:45:00','919194','Alitalia',48),(258,4,17,'2025-04-16 10:30:00','2025-04-16 16:40:00','732726','Alitalia',180),(259,17,5,'2025-04-16 09:00:00','2025-04-16 09:47:00','332329','Alitalia',26),(260,7,20,'2025-04-16 10:00:00','2025-04-16 11:30:00','998880','Alitalia',61),(261,25,7,'2025-04-16 19:10:00','2025-04-16 22:20:00','192902','Emirates',200),(262,23,20,'2025-04-16 16:10:00','2025-04-16 17:10:00','189294','Alitalia',58),(263,1,23,'2025-04-16 19:10:00','2025-04-16 22:20:00','746532','Alitalia',180),(264,3,1,'2025-04-16 22:30:00','2025-04-16 23:35:00','739204','Emirates',100),(265,4,1,'2025-04-16 22:15:00','2025-04-16 23:30:00','293013','Lufthansa',78),(266,4,6,'2025-04-16 15:45:00','2025-04-16 17:50:00','295336','Lufthansa',100),(267,6,23,'2025-04-16 10:40:00','2025-04-16 12:30:00','993455','Alitalia',91),(268,4,20,'2025-04-16 07:20:00','2025-04-16 12:30:00','987656','Emirates',350),(269,21,20,'2025-04-16 08:10:00','2025-04-16 09:20:00','444447','Alitalia',57),(270,4,21,'2025-04-16 13:10:00','2025-04-16 16:00:00','888891','Lufthansa',125),(271,12,5,'2025-04-16 08:30:00','2025-04-16 17:50:00','543219','Emirates',785),(272,5,22,'2025-04-16 14:15:00','2025-04-16 14:50:00','902381','Alitalia',22),(273,5,20,'2025-04-16 06:20:00','2025-04-16 08:25:00','901286','Alitalia',79),(274,4,5,'2025-04-16 13:00:00','2025-04-16 16:05:00','384925','Emirates',275),(275,1,20,'2025-04-16 08:40:00','2025-04-16 11:25:00','029303','Alitalia',100),(276,24,1,'2025-04-16 14:10:00','2025-04-16 17:00:00','009998','Emirates',195),(277,4,24,'2025-04-16 19:00:00','2025-04-16 21:50:00','666680','Ryanair',130),(278,10,20,'2025-04-16 04:30:00','2025-04-16 09:20:00','923459','Ryanair',92),(279,4,10,'2025-04-16 11:20:00','2025-04-16 13:20:00','900224','Airfrance',170),(280,19,20,'2025-04-16 02:10:00','2025-04-16 03:15:00','022436','Alitalia',92),(281,8,19,'2025-04-16 05:15:00','2025-04-16 08:10:00','832991','Lufthansa',125),(282,4,8,'2025-04-16 09:15:00','2025-04-16 10:35:00','777890','Ryanair',91),(283,14,19,'2025-04-16 04:00:00','2025-04-16 08:00:00','966269','Emirates',150),(284,13,19,'2025-04-16 09:20:00','2025-04-16 19:00:00','299998','Ryanair',400),(285,17,20,'2025-04-16 01:00:00','2025-04-16 02:10:00','392994','Alitalia',50),(286,3,17,'2025-04-16 04:30:00','2025-04-16 07:30:00','562103','Ryanair',190),(287,4,3,'2025-04-16 10:30:00','2025-04-16 12:10:00','664423','Ryanair',90);
/*!40000 ALTER TABLE `voli` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER delete_related_ricerche

BEFORE DELETE ON voli

FOR EACH ROW

BEGIN

    #Inserisce il messaggio nella tabella messaggi_sistema per ogni utente che ha ricerche associate al volo eliminato

    INSERT INTO messaggi_sistema (username, messaggio)

    SELECT DISTINCT username, 

           CONCAT('Una tua ricerca è stata automaticamente eliminata dal sistema causa cancellazione di uno o più voli.')

    FROM ricerche

    WHERE id_ricerca IN (

        SELECT DISTINCT id_ricerca

        FROM ricerche_voli

        WHERE id_volo = OLD.id

    );



    #Elimina le ricerche che sono associate al volo eliminato

    DELETE FROM ricerche

    WHERE id_ricerca IN (

        SELECT DISTINCT id_ricerca

        FROM ricerche_voli

        WHERE id_volo = OLD.id

    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-02  9:26:50
