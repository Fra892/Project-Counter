<?php
    // connessione al database
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";
    
    session_start();
    $connection = db_connect();
    $airports_query =  "SELECT nome, codice_iata
                         FROM aeroporti 
                         ORDER BY nome";
    $sql_result = mysqli_query($connection,$airports_query);
    // recuperiamo tutti i gli aeroporti
?>

<!DOCTYPE html>
<html lang = "it">
    <head>
        <meta charset = "utf-8">
        <title>Space Cowboy Flight Finder</title>
        <link rel = "stylesheet" href = "../../css/NavBar.css">
        <link rel = "stylesheet" href = "../../css/home.css">
        <script src = "../../js/utils.js"></script>
        <script src = "../../js/home.js"></script>
        <meta name = "viewport" content = "width = device-width">
        <meta name = "author" content = "Francesco Vesigna">
        <meta name = "description" content = "Main Page of Space Cowboy flight finder">
    </head> 
    <body onload = "init()">
        <div id = "wrapper">
            <div id = "title">
                <h1>Space Cowboy</h1>
            </div>
            <div id = "NavBar">
                <?php if(isset($_SESSION["username"]) && $_SESSION["username"] === "admin"): ?>
                    <a href = "gestione.php"> Gestione </a>
                <?php endif; ?>
                <?php if(isset($_SESSION["username"])): ?>
                    <a href = "preferiti.php"> Preferiti </a>
                    <a href = "logout.php"> Logout </a>
                <?php else: ?>
                    <a href = "login.php"> Login </a>
                <?php endif; ?>
                <a href = "../../html/guida.html"> Guida </a>
            </div>
        </div>  
        <div id = "SearchArea">
            <div id = "SearchBar" class = "invalid">
                <div id = "Da" class = "elems">
                    <label id = "Da-label" for = "Da-input"> Da </label><br>
                    <div class = "select-div">
                        <select id = "Da-select" name = "A-select-name">
                        <?php 
                            if(isset($sql_result)){
                                while($row = mysqli_fetch_assoc($sql_result)){
                                    echo "<option value='" . $row['codice_iata'] . "'> " . $row['nome'] . " (" . $row['codice_iata'] . ") </option>";
                                }
                            }
                        ?>
                        </select>
                    </div>

                </div>
                <hr>
                <div id = "A" class = "elems">
                    <label id = "A-label" for = "A-input"> A </label><br>
                    <div class ="select-div">
                        <select id = "A-select" name = "A-select-name">
                        <?php 
                            if(isset($sql_result)){
                                // l'iteratore deve ritornare al primo record
                                mysqli_data_seek($sql_result, 0);
                                while($row = mysqli_fetch_assoc($sql_result)){
                                    echo "<option value='" . $row['codice_iata'] . "'> " . $row['nome'] . " (" . $row['codice_iata'] . ") </option>";
                                }
                            }
                        ?>
                        </select>
                    </div>
                </div>
                <hr>
                <div id = "Partenza" class = "elems">
                    <label id = "Partenza-label" for = "Partenza-input"> Partenza </label><br>
                    <input id = "Partenza-input" type = "date" required>
                </div>
                <hr>
                <div id = "Ritorno" class = "elems">
                    <label id = "Ritorno-label" for = "Ritorno-input"> Ritorno </label><br>
                    <input id = "Ritorno-input" type = "date" required>
                </div>
            </div>
        </div>
        <div id = "cerca-div">
            <button id = "cerca" type = "button"> Cerca </button>
        </div>

        <div id = "result-area">
            
        </div>
    </body>
</html>  

