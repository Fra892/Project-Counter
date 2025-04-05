<?php
    require_once "class_graph.php";
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";
    require_once "../preferiti/check_preferiti.php";


    session_start();
    header('Content-Type: application/json');
    $requestData = file_get_contents('php://input');
    $data = json_decode($requestData, true);
    if($data === null){
        echo json_encode(['error' => 'dati non validi']);
        exit;
    }
    // PRELEVO I VALORI
    $partenza = $data['partenza'];
    $info = $data['info'];
    $da = $data['da'];
    $a = $data['a'];
    $ritorno = "";
    if($info === "andata_ritorno"){
        $ritorno = $data['ritorno'];
    }
    // VALIDATE LATO SERVER
    function validate_data($da, $a, $partenza, $ritorno,$info){
        $connection = db_connect();
        $stmt = mysqli_prepare($connection,"SELECT a.id
                                            FROM aeroporti a
                                            WHERE a.codice_iata = ? OR a.codice_iata = ?");
        mysqli_stmt_bind_param($stmt,"ss",$da,$a);
        if(!mysqli_stmt_execute($stmt)){
            mysqli_stmt_close($stmt);
            return "errore nella validazione";
        }
        
        $res = mysqli_stmt_get_result($stmt);
        if(mysqli_num_rows($res) != 2){
            mysqli_stmt_close($stmt);
            return "aeroporti non validi";
        }
        mysqli_stmt_close($stmt);
        // in questo caso se il client mi ha mandato andata-ritorno controllo come se fosse andata-ritorno 
        // !!la funzione non è speculare (se il ritorno è invalido ma c'è andata-ritorno segnalerà un errore )
        // conversione di partenza e ritorno
        $partenza_date = DateTime::createFromFormat('Y-m-d',$partenza);
        if($info  === "andata_ritorno"){
            $ritorno_date = DateTime::createFromFormat('Y-m-d',$ritorno);
        }

        if($partenza_date === false){
            return "data non valida";
        }

        if($partenza_date < new DateTime()){
            return "la data di partenza deve avvenire prima di oggi";
        }
        if($info === "andata_ritorno"){
            if($ritorno_date === false){
                return "data non valida";
            }
            if($partenza_date >= $ritorno_date){
                return "Non puoi tornare indietro nel tempo";
            }
        }
        
        return true;
    }

    $validation_result = validate_data($da,$a,$partenza,$ritorno,$info);
    if($validation_result !== true){
        echo json_encode(['error' => $validation_result]);
        exit;
    }
    // serve per la gestione dei preferiti
    $logged_in = (isset($_SESSION["username"]))? $_SESSION["username"]: "non loggato";
    // conversione in formato date time per la query
    $partenza_date = DateTime::createFromFormat('Y-m-d',$partenza);
    $partenza_date_time = $partenza_date->format('Y-m-d 00:00:00');
    // viene passata come stringa conenente la data in formato date time 
    $adj_mat_andata = new graph($partenza_date_time);
    $tratte_trovate_andata = $adj_mat_andata->solve($da,$a);
    if($logged_in !== "non loggato"){
        check_preferiti($tratte_trovate_andata,$logged_in);
    }
    $tratte_trovate_ritorno = [];
    if($ritorno != ""){
        $ritorno_date = DateTime::createFromFormat('Y-m-d',$ritorno);
        // la passiamo come una stringa 
        $ritorno_date_time = $ritorno_date->format('Y-m-d 00:00:00');
        $adj_mat_ritorno = new graph($ritorno_date_time);
        $tratte_trovate_ritorno = $adj_mat_ritorno->solve($a,$da);
        if($logged_in !== "non loggato"){
            check_preferiti($tratte_trovate_ritorno,$logged_in);
        }
    }
    // check preferiti aggiunge l'id dell'utente se loggato oppure la stringa non loggato 
    // inoltre se appare tra i preferiti la marca con l'id della ricerca dell'utente

    // non loggato NON può essere un username per via dello spazio bianco

    // controllo sulla conversione in JSON
    $risposta = json_encode(['tratte_andata' => $tratte_trovate_andata,
                             'tratte_ritorno' => $tratte_trovate_ritorno,
                             'info'           => $data['info'],
                             'logged_in'      => $logged_in]);
    if ($risposta === false) {
        echo json_encode(['error' => 'Errore nella codifica JSON']);
        exit;
    }
    // trasmetto al client la risposta
    echo $risposta;
?>