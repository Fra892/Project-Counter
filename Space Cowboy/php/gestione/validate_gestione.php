<?php
    function validate($da,$a,$giorno,$partenza = null, $arrivo = null,$compagnia = null, $codice = null,$prezzo = null){
        // questa funzione viene chiamata sia da aggiungi_volo che da elimina volo
        $connection = db_connect();
        // controllo aeroporti
        $stmt = mysqli_prepare($connection,"SELECT *
                                            FROM aeroporti a
                                            WHERE id = ? OR id = ?");
        mysqli_stmt_bind_param($stmt,"ss",$da,$a);

        // errore nell'esecuzione
        if(!mysqli_stmt_execute($stmt)){
            mysqli_stmt_close($stmt);
            return "errore nella validazione";
        }
        // errore (2 aerporti uguali o aerporti non trovati)
        $res = mysqli_stmt_get_result($stmt);

        if(mysqli_num_rows($res) !== 2){
            mysqli_stmt_close($stmt);
            return "aeroporti non validi";
        }

        // controllo del formato del giorno
        $giorno_date = DateTime::createFromFormat('Y-m-d',$giorno);
        if(!$giorno_date){
            return "giorno non valido";
        }
        if($giorno_date < new DateTime()){
            return "il giorno deve essere successivo a oggi";
        }

        // se siamo viene chiamata in aggiungi_volo verranno fatte anche questi controlli
        if($partenza !== null && $arrivo !== null){
            $partenza_time = DateTime::createFromFormat('H:i:s',$partenza);
            $arrivo_time = DateTime::createFromFormat('H:i:s',$arrivo);
            

            // formato delle date
            if(!$partenza_time || !$arrivo_time){
                return "orari non validi";
            }

            // validità delle date
            if($partenza >= $arrivo){
                return "orari non validi";
            }
        }
        // validità del codice alfanumerico
        if($codice !== null && strlen($codice) !== 6){
            return "il codice del volo deve essere di 6 caratteri";
        }

        // controllo che non ci sia un altro volo operato dalla stessa compagnia con stesso codice
        if($compagnia !== null && $codice !== null){
            $stmt = mysqli_prepare($connection,"SELECT *
                                                FROM voli
                                                WHERE compagnia_aerea = ? AND codice_volo = ?");
            mysqli_stmt_bind_param($stmt,"ss",$compagnia,$codice);

            // errore nell'esecuzione
            if(!mysqli_stmt_execute($stmt)){
                mysqli_stmt_close($stmt);
                return "errore nella validazione";
            }
            $res = mysqli_stmt_get_result($stmt);
            // esiste già un risultato non è unico 
            if(mysqli_num_rows($res)){
                mysqli_stmt_close($stmt);
                return "volo già presente";
            }
            mysqli_stmt_close($stmt);
        }

        // controllo del prezzo
        // deve avere due deciamali se specificato (esempio 12.4 X   12.40 V) separati da una virgola
        if (!preg_match("/^\d+(\.\d{2})?$/", $prezzo)) {
            return "Il prezzo deve avere due decimali";
        }
        return true;
    }

?>