<?php
// connessione al database
require_once "../utils/db_parameter.php";
require_once "../utils/db_connect.php";
require_once "../gestione/validate_gestione.php";

$connection = db_connect();
$airports_query =  "SELECT id,codice_iata,nome
                     FROM aeroporti 
                     ORDER BY nome";
$sql_result = mysqli_query($connection,$airports_query);
$msg = "";

if($_SERVER["REQUEST_METHOD"] === "POST"){
    if($_POST["action"] === "svuota"){
        $fino_al = $_POST["finoal-svuota"];
        $fino_al_date = DateTime::createFromFormat("Y-m-d",$fino_al);
        if(!$fino_al_date){
            $msg = "formato non corretto";
        } else if($fino_al_date >= new DateTime()){
            $msg = "la data deve essere precedente a oggi";
        } else {
            $delete_query = "DELETE
                             FROM voli
                             WHERE data_partenza <  ?";
            $param = $fino_al . " 00:00:00";
            $stmt = mysqli_prepare($connection,$delete_query);
            mysqli_stmt_bind_param($stmt,"s",$param);
            if(!mysqli_stmt_execute($stmt)){
                $msg = "errore nella esecuzione";
            } else {
                $msg = "operazione completata";
            }
            mysqli_stmt_close($stmt);
        }
    } else if($_POST["action"] === "elimina"){
        $da = $_POST["da-elimina"];
        $a = $_POST["a-elimina"];
        $giorno = $_POST["giorno-elimina"];
        $msg = validate($da,$a,$giorno);
        if($msg === true){
            $delete_query = "DELETE 
                             FROM voli
                             WHERE data_partenza >= ? AND data_partenza <= ? AND aeroporto_partenza = ? AND aeroporto_arrivo = ?";
            $begin = $giorno." 00:00:00";
            $end = $giorno. " 23:59:59";  
            $stmt = mysqli_prepare($connection,$delete_query);
            mysqli_stmt_bind_param($stmt,"ssss",$begin,$end,$da,$a);
            if(!mysqli_stmt_execute($stmt)){
                $msg = "errore nella esecuzione";
            } else {
                $msg = "operazione completata";
            } 
            mysqli_stmt_close($stmt);          
        }
    } else if($_POST["action"] === "aggiungi"){
        $da = $_POST["da-aggiungi"];
        $a = $_POST["a-aggiungi"];
        $orario_partenza = $_POST["partenza-aggiungi"].":00";
        $orario_arrivo = $_POST["arrivo-aggiungi"].":00";
        $compagnia = $_POST["compagnia-aggiungi"];
        $codice = $_POST["codice-aggiungi"];
        $giorno = $_POST["giorno-aggiungi"];
        $prezzo = $_POST["prezzo-aggiungi"];

        // controlli di validità (controllare validate gestione per i controlli effettuati)
        $msg = validate($da,$a,$giorno,$orario_partenza,$orario_arrivo,$compagnia,$codice,$prezzo);

        if($msg === true){
            // dobbiamo controllare che non esista un altro volo con stessa compagnia aerea e stesso codice
            $check_query = "SELECT *
                            FROM voli
                            WHERE comapgnia_aerea = ? AND codice_volo = ?";
            $stmt = mysqli_prepare($connection,$check_query);
            mysqli_stmt_bind_param($stmt,"ss",$compagnia,$codice);
            if(!mysqli_stmt_execute($stmt)){
                $msg = "errore nell'esecuzione";
            } else {
                $res = mysqli_stmt_get_result($stmt);
                // se il result set non è vuoto allora c'è un errore
                if(mysqli_num_rows($res)){
                    $msg = "Esiste già un volo con stesso codice e stessa compagnia";
                } else {
                    // validazione completata
                    $insert_query = "INSERT INTO voli (aeroporto_partenza,aeroporto_arrivo,data_partenza,data_arrivo,compagnia_aerea,codice_volo,prezzo)
                    VALUES (?,?,?,?,?,?,?)";
                    $data_partenza = $giorno . " ". $orario_partenza;
                    $data_arrivo = $giorno." ".$orario_arrivo;
                    $stmt = mysqli_prepare($connection,$insert_query);
                    mysqli_stmt_bind_param($stmt,"ssssssd",$da,$a,$data_partenza,$data_arrivo,$compagnia,$codice,$prezzo);
                    if(!mysqli_stmt_execute($stmt)){
                        $msg = "errore nella esecuzione";
                    } else {
                        $msg = "operazione completata";
                    } 
                    mysqli_stmt_close($stmt);
                }
            }
        } 
    }  
}

?>

<!DOCTYPE html>
<html lang = "it">
    <head>
        <meta charset = "utf-8">
        <title>Space Cowboy Flight Finder</title>
        <link rel = "stylesheet" href = "../../css/gestione.css">
        <link rel = "stylesheet" href = "../../css/NavBar.css">
        <meta name = "viewport" content = "width = device-width">
        <meta name = "author" content = "Francesco Vesigna">
        <meta name = "description" content = "Management page of the website">
    </head> 
    <body>
        <div id = "wrapper">
            <div id = "title">
                <h1>Space Cowboy</h1>
            </div>
            <div id = "NavBar">
                <a href = "home.php"> Home </a>
                <a href = "../../html/guida.html"> Guida </a>
            </div>
        </div> 
        <div id = "flex">
            <div class = "flex-form">
                <form id="elimina-voli" method="POST">
                    <input type="hidden" name="action" value="elimina"> 
                    <h2>Elimina</h2>
                    <div>
                        <label for="da-elimina">Da</label>
                        <select id = "da-elimina" name = "da-elimina">
                        <?php
                            if(isset($sql_result)){
                                while($row = mysqli_fetch_assoc($sql_result)){
                                    echo "<option value='" . $row['id'] . "'> " . $row['nome'] . " (" . $row['codice_iata'] . ") </option>";
                                }
                            }
                        ?>
                        </select>
                    </div>
                    <div>
                        <label for="a-elimina"> A </label>
                        <select id = "a-elimina" id = "a-elimina" name = "a-elimina">
                        <?php
                            mysqli_data_seek($sql_result,0);
                            if(isset($sql_result)){
                                while($row = mysqli_fetch_assoc($sql_result)){
                                    echo "<option value='" . $row['id'] . "'> " . $row['nome'] . " (" . $row['codice_iata'] . ") </option>";
                                }
                            }
                        ?>
                        </select>
                    </div>
                    <div>
                        <label for= "giorno-elimina"> Giorno </label>
                        <input type = "date" id = "giorno-elimina" name = "giorno-elimina" required>
                    </div>
                    <div id = "pulsantiera-elimina">
                        <input type="submit" id="elimina" value="Elimina">
                    </div>
                </form>
            </div>
            <div class = "grid-form">
                <form id="aggiungi-volo" method="POST">
                    <input type="hidden" name="action" value="aggiungi"> 
                    <h2>Aggiungi</h2>
                    <div>
                            <label for="da-aggiungi">Da</label>
                            <select id = "da-aggiungi" id = "da-aggiungi" name = "da-aggiungi">
                            <?php
                                mysqli_data_seek($sql_result,0);
                                if(isset($sql_result)){
                                    while($row = mysqli_fetch_assoc($sql_result)){
                                        echo "<option value='" . $row['id'] . "'> " . $row['nome'] . " (" . $row['codice_iata'] . ") </option>";
                                    }
                                }
                            ?> 
                            </select>
                            <label for = "a-aggiungi"> A </label>
                            <select id = "a-aggiungi" id = "a-aggiungi" name = "a-aggiungi"> 
                            <?php
                                mysqli_data_seek($sql_result,0);
                                if(isset($sql_result)){
                                    while($row = mysqli_fetch_assoc($sql_result)){
                                        echo "<option value='" . $row['id'] . "'> " . $row['nome'] . " (" . $row['codice_iata'] . ") </option>";
                                    }
                                }
                            ?>
                            </select>

                            <label for= "partenza-aggiungi">Parte</label>
                            <input type = "time" id = "partenza-aggiungi" name="partenza-aggiungi" required>

                            <label for="arrivo-aggiungi"> Arriva </label>
                            <input type = "time" id = "arrivo-aggiungi" name = "arrivo-aggiungi" required>

                            <label for= "compagnia-aggiungi">Compagnia</label>
                            <input type = "input" id = "compagnia-aggiungi" name = "compagnia-aggiungi" required>

                            <label for = "codice-aggiungi"> Codice </label>
                            <input type = "input" id = "codice-aggiungi" name = "codice-aggiungi"  required pattern = "^[0-9]{6}$">
                            
                            <label for= "giorno-aggiungi"> Giorno </label>
                            <input type = "date" id = "giorno-aggiungi" name = "giorno-aggiungi" required>
                            <label for ="prezzo-aggiungi"> Prezzo </label>
                            <input type = "number" id = "prezzo-aggiungi" name = "prezzo-aggiungi" required min="0.01" step="0.01" pattern="^\d+(\.\d{1,2})?$">
                    </div>  
                    <div id = "pulsantiera-aggiungi">
                        <input type="submit" id="aggiungi" value="Aggiungi">
                    </div>
                </form>
            </div>
            <div class = "flex-form">
                <form id="svuota-voli" method="POST">
                    <input type="hidden" name="action" value="svuota"> 
                    <h2>Svuota</h2>
                    <div>
                        <label for="date_until">Fino al </label>
                        <input type="date" id="finoal-svuota" name="finoal-svuota">
                    </div>
                    <div id = "pulsantiera-svuota">
                        <input type = "submit" id = "svuota" value = "Svuota">
                    </div>
                </form>
            </div>
        </div>
        <div id = "result">
            <?php 
                if($msg !== ""){
                    if($msg === "operazione completata"){
                        echo "<p id = 'msg' class = 'valido' >".$msg."</p>";
                    } else {
                        echo "<p id = 'msg' class = 'invalido'>".$msg. "</p>";
                    }   
                } 
            ?>     
        <div>
    </body>
</html>