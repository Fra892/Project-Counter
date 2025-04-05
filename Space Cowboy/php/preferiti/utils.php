<?php
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";


    // @UTILS RITORNA TUTTI GLI ID ASSOCIATI A USER
    function get_ids_from_username($logged_in){
        $connection = db_connect();
        // prendiamo gli id-ricerca dell'utonto
        // ogni id_ricerca corrisponde a una tratta salvata nei preferiti degli utenti
        $id_query = "SELECT r.id_ricerca as id 
                     FROM ricerche r
                     WHERE r.username = '$logged_in'";
        // prendiamo solo le tratte salvate da username
        $id_result = mysqli_query($connection,$id_query);
        return $id_result;
        // ritorna un result set mysqli 
    }


    //@fUTILS  RITORNA TUTTI I VOLI ASSOCIATI A UN ID_RICERCA
    function get_flights_from_id($id_ricerca){
        $connection = db_connect();
        $query_flights = "SELECT rv.id_volo , v.data_partenza, v.data_arrivo, 
                                 v.compagnia_aerea , a1.codice_iata AS aeroporto_partenza, a2.codice_iata AS aeroporto_arrivo, 
                                 v.prezzo, v.codice_volo
                          FROM ricerche_voli rv INNER JOIN voli v ON v.id = rv.id_volo 
                               INNER JOIN aeroporti a1 ON a1.id = v.aeroporto_partenza 
                               INNER JOIN aeroporti a2 ON a2.id = v.aeroporto_arrivo 
                          WHERE rv.id_ricerca = $id_ricerca 
                          ORDER BY v.data_partenza";
        $res = mysqli_query($connection,$query_flights);
        return $res;
    }


    // NOTA: QUESTE FUNZIONI SONO ASSOCIATE O AL SOLVER CHE ACCEDE DIRETTAMENTE ALLA SESSION O ALLO SCRIPT
    // get preferiti che viene chiamato subito lato server senza bisogno del client, perciò non ci preoccupiamo
    // delle sql injection



?>