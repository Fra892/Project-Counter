
// username dell'utente
let logged_in;
// visualizzazione contenuti
let prev_data_partenza = null;

function init(){
    // manda la richiesta 
    send_request();
}


function send_request(){
    // prendiamo i preferiti
    fetch('../preferiti/get_preferiti.php',{
        method: 'POST',
    })
    .then(response => {
        if(!response.ok){
            throw new Error('Errore nella risposta');
        } else {
            return response.text().then(text => {
                console.log('Risposta Raw del server:',text);
                try {
                    return JSON.parse(text); // ritorna una premessa
                } catch(e){
                    // error handling per errore sul json_encode
                    throw new Error('La risposta del server non è un JSON valido');
                }
            });
        }
    })
    .then(data => {
        logged_in = data.logged_in;
        let vett = sort_vector(data.tratte,get_data_partenza);
        // nel caso di eliminazione di qualche preferito da parte dell'admin
        // (ha eliminato un volo facente parte di una tratta preferita deve essere visualizzato)
        if(data.messaggio !== ""){
            alert(data.messaggio);
        }
        visualizza_content(vett);
    })
    .catch(error => alert(error));
}


function visualizza_content(tratte){
    const result_area = document.getElementById("result-area");
    tratte.forEach((tratta) => {
        // prendiamo la data 
        act_data_partenza = tratta.tratta[0].data_partenza.split(" ")[0].substring(0,10);
        // crea il separatore
        if(prev_data_partenza !== act_data_partenza){
            create_sep(act_data_partenza);
        }
        // le tratte sono già ordinate
        prev_data_partenza = act_data_partenza;

        const tratta_div = document.createElement("div");
        create_info_generali(tratta,tratta_div);

        const voli_div = document.createElement("div");
        voli_div.setAttribute("class","voli-container");
        
        // info compagnia voli
        create_info_container(tratta,voli_div,"info-linea-b","compagnia");
        // info aeroporti
        create_info_container(tratta,voli_div,"info-linea-a","aeroporto");
        // linea con i pallini
        crea_linea_visual(tratta,voli_div);
        // orari
        create_info_container(tratta,voli_div,"info-linea-a","data");
        // info codici voli
        create_info_container(tratta,voli_div,"info-linea-b","codice_volo");


        tratta_div.appendChild(voli_div);
        result_area.appendChild(tratta_div);
    });


}

function create_sep(act_data){
    const result_area = document.getElementById("result-area");
    const h2 = document.createElement("h2");
    h2.setAttribute("class","data-separatore")
    h2.innerText = act_data;
    result_area.appendChild(h2);
}




