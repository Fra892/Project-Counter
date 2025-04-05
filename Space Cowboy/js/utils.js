/* QUESTO FILE CONTIENE:
        - LE FUNZIONI PER LA GESTIONE DEI PREFERITI CHE è condivisa tra la HOME e I PREFERITI
        - FUNZIONI CONDIVISE PER LA VISUALIZZAZIONE DEL CONTENUTO, LE FUNZIONI SPECIFICHE SONO in preferiti.js e home.js
*/




// utlità per errori (@TODO: contemplare un cambiamento )
function show_error_dialog(err){
    alert(err);
}

// per mostrare in formato ore e minuti un intervallo
function get_ore_minuti(ore){
    let ore_intere = Math.floor(ore);
    let minuti = (ore - ore_intere) * 60;
    return [ore_intere, Math.round(minuti)];

}


// per aeroporti e orari
function crea_info_linea_a(tratta,key_to_get_a,key_to_get_b,HTMLel){
    let precedente = null
    let type = key_to_get_a.split("_")[0];
    tratta.forEach((volo) => {
        // se non abbiamo messo nessun elemento precedente nella flexbox allora la aggiungiamo noi
        if(precedente == null){
            const p_a = document.createElement("p");
            p_a.innerText = (type === "aeroporto")? volo[key_to_get_a]:
                            volo[key_to_get_a].split(" ")[1].substring(0,5);
            HTMLel.appendChild(p_a);
        } else {
            // se era un orario dobbiamo mettere l'orario di partenza 
            if(type === "data"){
                precedente.innerText += "/" + volo[key_to_get_a].split(" ")[1].substring(0,5);
            }
        }
        // e mettiamo il successivo
        const p_b = document.createElement("p");
        p_b.innerText = (type === "aeroporto")? volo[key_to_get_b]:
                        volo[key_to_get_b].split(" ")[1].substring(0,5);
        HTMLel.appendChild(p_b)
        precedente = p_b;
    });
}

// per compagnia e cod volo
function crea_info_linea_b(tratta,key_to_get,HTMLel){
    tratta.forEach((volo) => {
        const p = document.createElement("p");
        p.innerText = volo[key_to_get];
        HTMLel.appendChild(p);
    });
}

function create_info_generali(tratta,father){
    father.setAttribute("class","scheda-tratta");
        // wrapper info: prezzo tot e tempo tot e preferiti
    const gen_tratta_div = document.createElement("div");
    gen_tratta_div.setAttribute("class","scheda-tratta-info");
    const prezzo = document.createElement("p");
    const tempo = document.createElement("p");
    let prezzo_tot_tratta = get_prezzo(get_vect_login(tratta,logged_in));
    // i valori presi dal database avevano il punto dunque per la visualizzazione 
    // mettiamo la virgola
    prezzo.innerText = "Prezzo: "+ prezzo_tot_tratta.toString().replace(".",",") + " euro";
    let tempo_tot_tratta = get_tempo(get_vect_login(tratta,logged_in));
    let ore_minuti = get_ore_minuti(tempo_tot_tratta);
    tempo.innerText ="Tempo: " + 
                    (ore_minuti[0] > 0 ? ore_minuti[0] + "h" : "") + 
                    (ore_minuti[1] > 0 ? " " + ore_minuti[1] + "m" : "");

    gen_tratta_div.appendChild(prezzo);
    // vedere gestione preferiti
    inserisci_star(gen_tratta_div,tratta);
    gen_tratta_div.appendChild(tempo);
    father.appendChild(gen_tratta_div);
}

// disposizione delle info attorno alla linea 
function create_info_container(tratta,father,type,key){
    const info_linea = document.createElement("div");
    info_linea.setAttribute("class",type);
    if(type === "info-linea-a"){
        key_to_get_a = key +"_partenza";
        key_to_get_b = key +"_arrivo";
        // aeroporti e orari
        crea_info_linea_a(get_vect_login(tratta,logged_in),key_to_get_a,key_to_get_b,info_linea);
    } else {
        // codici e compagnie
        crea_info_linea_b(get_vect_login(tratta,logged_in),key,info_linea);
    }
    father.appendChild(info_linea)
}

// crea la linea e il div pallini overlayed (si veda css)
function crea_linea_visual(tratta,father){
    const div_tratta_visual = document.createElement("div");
    div_tratta_visual.setAttribute("class","visual");
    father.appendChild(div_tratta_visual);
    const hr = document.createElement("hr");
    div_tratta_visual.appendChild(hr);
    const container_pallini = document.createElement("div");
    container_pallini.setAttribute("class","pallini");
    crea_pallini(get_vect_login(tratta,logged_in),container_pallini);
    div_tratta_visual.appendChild(container_pallini);
}

// crea target e scali su hr 
function crea_pallini(tratta,father){
    for(let i = 0; i <= tratta.length; i++){
        const pallino = document.createElement("div");
        pallino.setAttribute("class","pallino")
        if(!i || i === tratta.length){
            pallino.classList.add("target");
        } else {
            pallino.classList.add("scalo");
        }
        father.appendChild(pallino);
    } 
}

// template per il sort
function sort_vector(tratte,callback){
    tratte.sort((tratta_1,tratta_2) => {
        cum_param1 = callback(get_vect_login(tratta_1,logged_in));
        cum_param2 = callback(get_vect_login(tratta_2,logged_in));
        return (cum_param1 > cum_param2)? 1 : -1;
    });
    return tratte;
}


// callbacks per sort
// tempo
function get_tempo(tratta){
    let partenza =  new Date(tratta[0].data_partenza);
    let arrivo = new Date(tratta[tratta.length - 1].data_arrivo);
    let diff_ms = arrivo.getTime() - partenza.getTime();
    let diff_hrs = diff_ms / (1000 * 60 * 60);
    return diff_hrs;
}
// prezzo
function get_prezzo(tratta){
    let prezzo_tot = tratta.reduce((a, b) => {
        return a + (b.prezzo * 1); // convesrsione b.prezzo è una stringa
      }, 0);
    return prezzo_tot;
}
// data partenza
function get_data_partenza(tratta){
    return tratta[0].data_partenza;
}
// data arrivo
function get_data_arrivo(tratta){
    return tratta[tratta.length - 1].data_arrivo;
}




// utility per selezionare un vettore di voli e non un oggetto contenente i voli e nel caso l'id ricerca 
function get_vect_login(tratta,logged_in){
    return (logged_in !== "non loggato")? tratta.tratta: tratta;
}

// inserisce l'elemento con cui l'utente dovrà interagire 
function inserisci_star(father,tratta){
    const wrapper = document.createElement("div");
    wrapper.setAttribute("class","star-container")
    const star = document.createElement("div");
    wrapper.appendChild(star);
    star.setAttribute("class", "star");
    // se è già stata calcolata tra i preferiti dal solver 
    // allora la dobbiamo segnare tra i preferiti
    if(logged_in !== "non loggato" && tratta["preferita"] !== false){
        star.classList.add("filled");
    }
    father.appendChild(wrapper);
    // FUNZIONE PER AGGIUNGERE / RIMUOVERE
    star.onclick = () => {
        toggle_preferiti(tratta,star)
    }
}


// prepare send per i preferiti
function toggle_preferiti(tratta,star){
    // se non siamo loggati non possiamo usare questa funzionalità
    if(logged_in === "non loggato"){
        show_error_dialog("devi essere loggato per poter usare questa funzionalità"); 
        return "non loggato";    
    }
    // non guardiamo la classe è più affidabile guardare il valore ritornato dal solver
    // l'utente potrebbe cambiare la classe della stella più facilmente
    let obj_to_send;
    if(tratta["preferita"] === false){
        // il solver non l'ha trovata tra i preferiti
        // cose da fare:
            // - aggiungere una ricerca alla tabella id_ricerca con user username
            // - aggiungere le entrate alla relazione ricerca_voli con gli id_voli della tratta
        obj_to_send = {
            tratta: tratta["tratta"],
            username: logged_in,
            info: "aggiungi"
        };
    } else {
        // prendere l'id ricerca ed eliminarlo, le relazioni verranno automaticamente 
        // eliminate (on cascade delete)
        obj_to_send = {
            tratta: tratta["tratta"],
            username: logged_in,
            info: "rimuovi",
            id_tratta: tratta["preferita"]

        };
    }
    toggle_preferiti_request(obj_to_send,tratta,star);
}


// richiesta toggle al server
function toggle_preferiti_request(data,tratta,star){
    fetch('../preferiti/toggle_preferiti.php', {
        method: 'POST',  
        headers: {
            'Content-Type': 'application/json'  
        },
        body: JSON.stringify(data) 
    })
    .then(response => {
        if(!response.ok){
            throw new Error("errore nella risposta del server");
        } else {
            return response.text().then(text => {
                console.log('Risposta Raw del server:', text);
                try {
                    return JSON.parse(text); // ritorna una premessa
                } catch (e) {
                    // per un error handling più elegante
                    throw new Error('La risposta del server non è un JSON valido');
                }
            });
        }
    })
    .then(data => {
        if(data.esito !== "richiesta completata"){
            throw new Error(data.esito);
        } else {
            // aggiungiamo al vettore locale così se fa il sorting appare preferita
            // e rivisualizza il contenuto appare preferita
            if(data.info === "aggiunta"){
                tratta["preferita"] = data.id_ricerca;
                star.classList.add("filled");
            } else {
                tratta["preferita"] = false;
                star.classList.remove("filled");
            }
        }
    })
    .catch(error => show_error_dialog(error));
}