<?php
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";

    session_start();
    header('Content-Type: application/json');
    $requestData = file_get_contents('php://input');
    $data = json_decode($requestData, true);
    // errore nel decode
    if($data === null){
        echo json_encode(['esito' => 'dati non validi']);
        exit;
    }

    $username = $data["username"];
    // controlliamo se lo username è lo stesso 
    if($username !== $_SESSION["username"]){
        echo json_encode(['esito' => 'username inconsistente']);
        exit;
    }
    $info = $data['info'];
    $connection = db_connect();
    if($info === 'aggiungi'){
        $tratta = $data["tratta"];
        $voli_id = [];
        $insert_query = "INSERT INTO ricerche (username) VALUES (?)";
        $stmt = mysqli_prepare($connection, $insert_query);
        mysqli_stmt_bind_param($stmt, "s", $username);
    
        if(!mysqli_stmt_execute($stmt)) {
            echo json_encode(['esito' => 'errore nell\'inserimento della ricerca']);
            exit;
        }
        // id generato dall'auto increment
        $id_generato = mysqli_insert_id($connection);
        foreach($tratta as &$volo){
            $insert_flight_query = "INSERT INTO ricerche_voli (id_ricerca, id_volo) VALUES (?, ?)";
            $stmt = mysqli_prepare($connection, $insert_flight_query);
            mysqli_stmt_bind_param($stmt, "ii", $id_generato, $volo["id"]);
            if (!mysqli_stmt_execute($stmt)) {
                echo json_encode(['esito' => 'errore nell\'inserimento dei voli']);
                exit;
            }                              
        }
        mysqli_stmt_close($stmt);
        echo json_encode(['esito' => 'richiesta completata',
                          'info' => 'aggiunta',
                          'id_ricerca' => $id_generato]);

    } else if($info === 'rimuovi') {
        $id_tratta = $data["id_tratta"];
        // controlliamo che la tratta è associata allo username richiedente
        $check_user_query = "SELECT username
                             FROM ricerche
                             WHERE id_ricerca = ?";
        $stmt = mysqli_prepare($connection,$check_user_query);
        mysqli_stmt_bind_param($stmt,"i",$id_tratta);
        if(!mysqli_stmt_execute($stmt)){
            echo json_encode(['esito' => 'errore']);
            exit;
        }
        $res = mysqli_stmt_get_result($stmt);
        if(!mysqli_num_rows($res)){
            echo json_encode(['esito' => 'errore']);
            exit;
        }
        $row = mysqli_fetch_assoc($res);
        if($row["username"] !== $username){
            echo json_encode(['esito' => 'questa tratta non è salvata tra i tuoi preferiti']);
            exit;
        }
        $delete_query = "DELETE 
                         FROM ricerche
                         WHERE id_ricerca = ?";
        $stmt = mysqli_prepare($connection,$delete_query);
        mysqli_stmt_bind_param($stmt,"i",$id_tratta);
        if(!mysqli_stmt_execute($stmt)){
            echo json_encode(['esito' => 'errore']);
            exit;
        }

        echo json_encode(['esito' => "richiesta completata",
                          'info'  => 'rimossa']);
    }
    // unreachable code 

?>