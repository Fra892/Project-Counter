

// GLOBAL per funzionalità @CERCA
let andata;  // elenco di tutte le tratte trovate per l'andata
let ritorno; // elenco di tutte le tratte trovate per il ritorno
let info_ritorno; // per capire se ritorno è significativo 

// GLOBAL per navigazione opzioni e sort
let selezionato = null;     // evitare sorting e evitare di caricare nuovo contenuto se è già caricato

// GLOBAL per funzionalità preferiti
let logged_in;          

// GLOBAL per navigazione opzioni e sort
let selected_sort_mode = null // per evitare di rifare il sorting se è già fatto

// CONST GLOBAL per visualizzazione
const LIMITE = 10; // massimo 25 tratte per la visualizzazione

// GLOBAL per gestione degli errori
let error = "inserisci i parametri di ricerca"







// entry-point
function init(){
    const da = document.getElementById("Da-select");
    const a = document.getElementById("A-select");
    const  partenza = document.getElementById("Partenza-input");
    const ritorno = document.getElementById("Ritorno-input");

    // validate
    da.onchange = check;
    a.onchange = check;
    partenza.onchange = check;
    ritorno.onchange = check;
    
    // prepare send
    const cerca = document.getElementById("cerca");
    cerca.addEventListener("click",find_flights);
    
}
// validazione visiva @TODO(controlli aggiuntivi)
function check(){
    // NOTA PER LE DATE:
    // - la validazione è automaticamente fatta dall'elemento html stesso
    // - per aggiungere sicurezza controlliamo che rispetti il formato date previsto  
    const da = document.getElementById("Da-select");
    const a = document.getElementById("A-select");
    const partenza = document.getElementById("Partenza-input");
    const ritorno = document.getElementById("Ritorno-input");

    // distinzione tra voli solo andata e solo ritorno (ritorno non valido)
    info_ritorno = (ritorno.value === "" || (ritorno.value !== "" &&  !Date(ritorno.value)))?
                    "solo_andata": "andata_ritorno";
    const SB = document.getElementById("SearchBar");

    // (controllo validazione dell'elemento html)
    if(partenza.value === ""){
        SB.classList.add("invalid");
        error = "la data di partenza ha formato invalido";
        return;
    }
    // (controllo ulteriore)
    if(!Date(partenza.value)){
        SB.classList.add("invalid");
        error = "la data di partenza ha formato invalido";
        return;
    }
    let oggi = new Date();
    let partenza_date = new Date(partenza.value);
    if(partenza_date < oggi){
        SB.classList.add("invalid");
        error = "la partenza non può avvenire prima di oggi";
        return;
    }
    // (non devono essere due aeroporti uguali)
    if(da.value === a.value){
        SB.classList.add("invalid");
        error = "gli aeroporti devono essere diversi"
        return;
    }

    // controllare che se c'è il ritorno ci sia una data e che avvenga dopo la partenza
    if(info_ritorno === "andata_ritorno"){
        let ritorno_date = new Date(ritorno.value);
        //(dopo la partenza)
        if(partenza_date >= ritorno_date){
            SB.classList.add("invalid");
            error = "la data di ritorno deve essere successiva alla data di partenza"
            return;
        }
        
    }
    error = null;
    SB.classList.remove("invalid");
}


// utlità generali
function clear_buttons(){
    const cerca_div = document.getElementById("cerca-div");
    cerca_div.innerHTML = "";
}

function clear_results(){
    const result_area = document.getElementById("result-area");
    result_area.innerHTML = "";
}


// callback per pulsante cerca
function find_flights(){
    // controllo se la searchbar è invalida
    // !! solo visivamente, la validazione viene fatta in modo più approfondita lato server !!
    const SB = document.getElementById("SearchBar");
    if(SB.classList.contains("invalid") || error !== null){
        show_error_dialog(error)
        return;
    }
    // tolgo cerca così finchè il solver non produce i risultati l'utente non può interagirci
    clear_buttons();
    
    //  preparazione dell'oggetto da mandare al solver
    let da = document.getElementById("Da-select").value;
    let a = document.getElementById("A-select").value;
    let partenza = document.getElementById("Partenza-input").value;
    let ritorno = document.getElementById("Ritorno-input").value;
    let obj_to_send; 
    if(info_ritorno === "solo_andata"){
        obj_to_send = {
            partenza: partenza,
            da: da,
            a: a,
            info: info_ritorno
        };
    } else {
        obj_to_send = {
            partenza: partenza,
            da: da,
            a: a,
            info: info_ritorno,
            ritorno: ritorno
        };
    } 
    send_request(obj_to_send);
}


// send cerca
function send_request(data) {
    // invio la richiesta
    fetch('../solver/solver.php', {
        method: 'POST',  
        headers: {
            'Content-Type': 'application/json'  
        },
        body: JSON.stringify(data)  
    })
    .then(response => {   
        // risposta del server (400)
        if (!response.ok) {
            throw new Error('Errore nella risposta del server');
        }
        // risposta del server (per DEBUG) e parsing del json in un oggetto js
        return response.text().then(text => {
            console.log('Risposta Raw del server:', text);
            try {
                return JSON.parse(text);
            } catch (e) {
                throw new Error('La risposta del server non è un JSON valido');
            }
        });
    })
    .then(result => {
        // se il server ha trovato errori nell'esecuzione del solver si interrompe 
        // e si fa un'altra rierca
        if(result.error){
            throw new Error(result.error);
        } else {
            // andate
            andata = result.tratte_andata;
            // ritorni
            ritorno = result.tratte_ritorno;
            // ci dice cosa ha cercato il server
            info = result.info;
            // username dell'utente
            logged_in = result.logged_in;
            mostra_opzioni(info);
        }     
    })
    .catch(error => {
        console.error('Errore nella richiesta:', error);
        show_error_dialog(error);
        reset_all();
    });
}




// navigazione
function mostra_opzioni(info){
    const cerca_div = document.getElementById("cerca-div");
    // andata 
    const btn_andata = document.createElement("button");
    btn_andata.id = "andata";
    btn_andata.innerText = "Andata";
    btn_andata.onclick = () => {visualizza_header("andata");};
    cerca_div.appendChild(btn_andata);

    // ritorno se richiesto 
    if(info === "andata_ritorno"){
        const btn_ritorno = document.createElement("button");
        btn_ritorno.id = "ritorno";
        btn_ritorno.innerText = "Ritorno";
        btn_ritorno.onclick = () => {visualizza_header("ritorno");};
        cerca_div.appendChild(btn_ritorno);
    }
    
    // nuova ricerca
    const indietro = document.createElement("button");
    indietro.id = "indietro";
    indietro.innerText = "Indietro";
    cerca_div.appendChild(indietro);
    indietro.onclick = reset_all;
}




// indietro
function reset_all(){
    // tolgo il menu di navigazione e i risultati
    clear_buttons();
    clear_results();

    
    // variabili globali legate alla ricerca vanno riportate allo
    // stato originale
    selected_sort_mode = null;
    selezionato = null;


    // rimetto il bottone per cercare nuove tratte
    const cerca = document.createElement("button");
    const cerca_div = document.getElementById("cerca-div");
    cerca_div.appendChild(cerca);
    cerca.innerText = "Cerca";
    cerca.onclick = find_flights;
}



// in base al bottone cliccato devo scegliere il vettore su cui iterare
function get_vett(){
    return (selezionato === "andata")? andata: ritorno;
}

// opzioni di visualizzazione
function visualizza_header(selected_button){
    // se sto ricliccando su ciò che sto già visualizzando non faccio niente
    if(selezionato === selected_button){
        return;
    }
    // mi ricordo se sono selezionate le andate o i ritorni
    clear_results();

    // prendo le tratte interessate
    let aux = (selected_button === "andata")? andata: ritorno;
    
    
    //info generali  
    const result_area = document.getElementById("result-area");
    const new_div = document.createElement("div");
    new_div.id = "info-generali";
    result_area.appendChild(new_div);
    // numero di tratte trovate
    const num_voli = document.createElement("h2");
    num_voli.innerText = "Tratte trovate: "+ aux.length;
    if(aux.length > LIMITE){
        num_voli.innerText += " (Mostrate 10)";
    }

    new_div.appendChild(num_voli);
    const hr = document.createElement("hr");
    new_div.appendChild(hr);

    // opzioni per la visualizzazione dei risultati
    const select_div = document.createElement("div");
    select_div.setAttribute("class","select-div");
    const select_sort = document.createElement("select");
    select_sort.innerHTML = " <option value = \"costo\"> ordina per costo </option>"+
                            " <option value = \"tempo\"> ordina per tempo  </option>"+
                            " <option value = \"partenza\"> ordina per partenza </option>"+
                            " <option value = \"arrivo\"> ordina per arrivo </option>";
    
    select_sort.id = "select-sort";
    select_div.appendChild(select_sort);
    new_div.appendChild(select_div);
    sort_results(selected_button);
    select_sort.onchange = () => { sort_results(selezionato);}
}

// interfaccia per il sort
function sort_results(selected_button){
    const select_sort = document.getElementById("select-sort");
    // se ho stesso sorting e stesso bottone allora posso ignorare
    if(selected_sort_mode === select_sort.value && selezionato === selected_button){
        return;
    }
    selezionato = selected_button;
    selected_sort_mode = select_sort.value;
    // salviamoci la modalità di sorting e il bottone selezionato nei globali
    let aux = get_vett();
    if(select_sort.value === "costo"){
        aux = sort_vector(aux,get_prezzo)
    } else if(select_sort.value === "tempo"){
        aux = sort_vector(aux,get_tempo)
    } else if(select_sort.value === "partenza"){
        aux = sort_vector(aux,get_data_partenza);
    } else if(select_sort.value === "arrivo"){
        aux = sort_vector(aux,get_data_arrivo)
    }
    // ripulire i risultati
    const result_area = document.getElementById("result-area");
    // solo le schede tratte non le info generali e l'ordinamento
    const tratte_divs = [...result_area.querySelectorAll('.scheda-tratta')]
    tratte_divs.forEach((div) => div.remove());
    visualizza_content(aux);
}



// visualizzazione tratte home 
function visualizza_content(tratte){
    const result_area = document.getElementById("result-area");
    tratte.forEach((tratta,idx) => {
        // massimo 20 tratte a schermo
        if(idx < LIMITE){
            //info generali (tempo e prezzo)
            const tratta_div = document.createElement("div");
            create_info_generali(tratta,tratta_div);

            // container per informazioni dei voli
            const voli_div = document.createElement("div");
            voli_div.setAttribute("class","voli-container");

            // sopra la linea gli aeroporti
            create_info_container(tratta,voli_div,"info-linea-a","aeroporto");
        
            // creo la linea
            crea_linea_visual(tratta,voli_div);


            // sotto la linea gli orari
            create_info_container(tratta,voli_div,"info-linea-a","data");
        
            // append everything
            tratta_div.appendChild(voli_div);
            result_area.appendChild(tratta_div);
        }
    });
}





