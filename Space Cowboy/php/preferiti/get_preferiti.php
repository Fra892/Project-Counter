<?php 
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";
    require_once "utils.php";

    
    session_start();
    $connection = db_connect();
    $tratte = [];
    $ids = get_ids_from_username($_SESSION["username"]);
    while($row = mysqli_fetch_assoc($ids)){
        $id = $row["id"];
        $flights = get_flights_from_id($id);
        $tratta = [];
        while($row_flight = mysqli_fetch_assoc($flights)){
            // get flights
            $flight_info = [
                'aeroporto_partenza' => $row_flight['aeroporto_partenza'],
                'aeroporto_arrivo'   => $row_flight['aeroporto_arrivo'],
                'data_partenza'      => $row_flight['data_partenza'],
                'data_arrivo'        => $row_flight['data_arrivo'],
                'codice_volo'        => $row_flight['codice_volo'],
                'prezzo'             => $row_flight['prezzo'],
                'compagnia'          => $row_flight['compagnia_aerea'],
                'id'                 => $row_flight['id_volo']
            ];
            $tratta[] = $flight_info;
        }
        $tratta = ['tratta' => $tratta,
                   'preferita' => $id];
        $tratte[] = $tratta;
        $tratta = [];  
    }
    // controllare messaggi sistema (messaggio in caso di eliminazione di qualche preferito)
    // da parte dell'admin
    $user = $_SESSION["username"];
    $query = "SELECT *
              FROM messaggi_sistema
              WHERE username = '$user'";
    $sql_result = mysqli_query($connection,$query);
    $messaggio = "";
    if(mysqli_num_rows($sql_result) > 1){
        $messaggio = "più ricerche sono state eliminate automaticamente dal sistema
                      causa cancellazione di uno o più voli";
    } else if(mysqli_num_rows($sql_result) === 1) {
        $row = mysqli_fetch_assoc($sql_result);
        $messaggio = $row["messaggio"];
    }
    $query_delete = "DELETE 
                     FROM messaggi_sistema
                     WHERE username = '$user'";
    mysqli_query($connection,$query_delete);
    // ora che verranno visualizzati i messaggi li togliamo per lo username loggato

              
    echo json_encode(['tratte' => $tratte,
                      'logged_in' => $_SESSION["username"],
                      'messaggio' => $messaggio]);
?>