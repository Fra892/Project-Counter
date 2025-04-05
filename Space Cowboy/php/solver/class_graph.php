<?php
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";
    
    class graph{
        // adj_matrix sarà la matrice di adiacenza vera e propria
        private $adj_mat = [];
        // map sarà un array che mapperà gli id degli aeroporti a 
        // all'indice corrispondente
        private $map = [];
        // N è la grandezza della matrice quadrata
        private $N;
        // il giorno al quale è associata la matrice di adiacenza
        private $partenza;


        function __construct($partenza){
            // settiamo la partenza
            $this->partenza = $partenza;
            // stabialiamo la connessione per le query
            $connection = db_connect();
        
            // recuperiamo gli id degli aeroporti
            $airports_query = " SELECT a.codice_iata
                                FROM aeroporti a";
            $airports_result = mysqli_query($connection,$airports_query);
            

            // costruiamo la mappa 
            while($row = mysqli_fetch_assoc($airports_result)){
                $this->map[] = $row['codice_iata'];

            }
            // [cod => idx] -> [idx => cod]
            $this->map = array_flip($this->map);

            // salviamo la dimensione (N x N)
            $this->N = count($this->map);

            // costruiamo la matrice di adiacenza 
            $this->adj_mat = array_fill(0,$this->N,array_fill(0,$this->N,[]));
            // prendiamo i voli dal database
            // NON serve il controllo sull'sql injection siccome abbiamo già controllato tutto 
            // lato server nel solver
            $flight_query = "SELECT v.id, a1.codice_iata AS aeroporto_partenza, a2.codice_iata AS aeroporto_arrivo, v.data_partenza, v.data_arrivo, v.codice_volo, v.prezzo, v.compagnia_aerea 
                             FROM voli v INNER JOIN aeroporti a1 ON a1.id = v.aeroporto_partenza INNER JOIN aeroporti a2 ON a2.id = v.aeroporto_arrivo 
                             WHERE v.data_partenza >= '$partenza' AND v.data_arrivo <= DATE_ADD('$partenza',INTERVAL 1 DAY)";
            $flight_result = mysqli_query($connection,$flight_query);
            // riempiamo la matrice di adiacenza 
            while($row = mysqli_fetch_assoc($flight_result)){
                $idx_departure = $this->map[$row['aeroporto_partenza']];
                $idx_arrival = $this->map[$row['aeroporto_arrivo']];
                // costruzione dell'oggetto 
                $flight_info = [
                    'aeroporto_partenza' => $row['aeroporto_partenza'],
                    'aeroporto_arrivo'   => $row['aeroporto_arrivo'],
                    'data_partenza'      => $row['data_partenza'],
                    'data_arrivo'        => $row['data_arrivo'],
                    'codice_volo'        => $row['codice_volo'],
                    'prezzo'             => $row['prezzo'],
                    'compagnia'          => $row['compagnia_aerea'],
                    'id'                 => $row['id']
                ];
                // per la dfs non è necessario aeroporto partenza e arrivo ma poi al client servono
                // per i preferiti
                $this->adj_mat[$idx_departure][$idx_arrival][] = $flight_info;
            }
        }

    
        private function dfs($da,$a,$act_time,&$tratta,&$sol,&$visited){
            // controlliamo se l'aeroporto è stato già visitato
            if($visited[$da] === true){
                return;
            }
            $visited[$da] = true;
            // siamo arrivati dunque si aggiunge la tratta trovata alla soluzione
            if($da == $a){
                $sol[] = $tratta;
                return;
            }
            // massimo 3 scali
            if(count($tratta) == 3){
                return;
            }
            // iterazione sulla matrice di adiacenza
            for($a_it = 0; $a_it < $this->N; $a_it++){
                // non ci sono voli che vanno da i a j
                if(!count($this->adj_mat[$da][$a_it])){
                    continue;
                }
                // controlliamo le informazioni dei voli da i a j
                for($it = 0; $it < count($this->adj_mat[$da][$a_it]); $it++){
                    // il volo parte prima di quando arriviamo
                    if($act_time > $this->adj_mat[$da][$a_it][$it]['data_partenza']){
                        continue;
                    }
                    // il volo va bene aggiungiamolo alla tratta
                    $tratta[] = $this->adj_mat[$da][$a_it][$it];
                    // rieseguiamo ricorsivamente la funzione dal nuovo punto di partenza
                    $this->dfs($a_it,$a,$this->adj_mat[$da][$a_it][$it]['data_arrivo'],$tratta,$sol,$visited);
                    // la tratta non andava bene dunque siamo tornati qui
                    // togliamo l'ultimo volo
                    $last_flight = array_pop($tratta);
                    // e marchiamo come non visitato l'aeroporto che abbiamo tolto che ovviamente 
                    // e quello con indice a_it
                    $visited[$a_it] = false;
                }
            }

        }

        public function solve($da,$a){
            $tratta = [];
            $sol = [];
            $visited = array_fill(0,$this->N,false);
            $da_mapped = $this->map[$da];
            $a_mapped = $this->map[$a];
            $this->dfs($da_mapped,$a_mapped,$this->partenza,$tratta,$sol,$visited);
            return $sol;
        }
    }

    
    //   SPIEGAZIONE DELLA STRUTTURA DELLA CLASSE E DEL METODO SOLVE

        /* forma della matrice
            ___________________________
            | x |   |                  |
            --------------------------- 
            |   |   |                  |
            ----------------------------
            |   |   |                  |
            ----------------------------
            |   |   |                  |
            ----------------------------
            |   |   |                  |
            ----------------------------
            ALTEZZA = N Aeroporti
            LUNGHEZZA = N Aeroporti
            In ogni intersezione i-j avremo un array di oggetti contenti:
                prezzo:
                data_partenza:
                data_arrivo:
                codice_volo:
                compagnia:
            PER OGNI RICERCA SI SUPPONE CHE SI ARRIVI IN MASSIMO UN GIORNO.
            La struttura dati difatti prende in considerazione solo i voli che partono il giorno di partenza
            e arrivano e entro il giorno di partenza
        */
        /* metodo solve

            Per quanto riguarda la ricerca si farà una dfs del grafo
            Questo vuol dire che ci sarà un aeroporto di partenza

            Per risolvere tratte di questo tipo
            Roma - Milano -- Milano - Roma -- Roma - Napoli.

            usiamo una struttura dati visited che fa backtrack appena rileva un ciclo.
            per ottimizzare il più possibile la ricerca, essa viene fermata dopo 3 voli trovati.  
        */  
    
        
?>