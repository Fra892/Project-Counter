<?php 
    require_once "utils.php";

    function check_preferiti(&$tratte,$logged_in){

        //prendiamo gli id di ricerca dell'utonto
        $id_result = get_ids_from_username($logged_in);

        foreach($tratte as &$tratta){
            if(!mysqli_num_rows($id_result)){
                $tratta = ['tratta' => $tratta,
                           'preferita' => false];
                
                continue;
            }
            $voli_ids_trovati = [];
            // controlliamo gli id dei voli trovati
            foreach($tratta as &$volo){
                $voli_ids_trovati[] = $volo["id"];
            }
            
            $found = false;
            mysqli_data_seek($id_result, 0);
            while($row = mysqli_fetch_assoc($id_result)){
                // vediamo a che voli è associata questa tratta 
                $id = $row["id"];
                // differenzio i ritorni dalle andate o altri percorsi con stessi nodi 
                // con order by data partenza
                $flight_result = get_flights_from_id($id);
                // questi rappresentano la tratta fixando un id ricerca dell'utente generico
                $voli_ids_db = array_column(mysqli_fetch_all($flight_result,MYSQLI_ASSOC),"id_volo");
                // se hanno lunghezza diversa sono per forza diversi
                if(count($voli_ids_db) != count($voli_ids_trovati)){
                    continue;
                }
                // sono uguali?
                if(compare_vectors($voli_ids_db,$voli_ids_trovati)){
                    // trovato un match
                    $tratta = ['tratta' => $tratta,
                               'preferita' => $id];
                    $found = true;
                    break;
                } 

            }
            if($found === false){
                $tratta = ['tratta' => $tratta,
                           'preferita' => false];
            }
        }
    }
    // utility per comparare due vettori
    function compare_vectors(&$arr1,&$arr2){
        for($i = 0; $i < count($arr1); $i++){
            // i tipi sono diversi da una parte abbiamo stringhe dalla parte 
            // quelli prelevati dal db sono int
            if($arr1[$i] != $arr2[$i]){
                return false;
            }
        }
        return true;
    }



?>