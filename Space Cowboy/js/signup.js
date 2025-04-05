

function init(){
    const username = document.getElementById("userSignup");
    username.setCustomValidity("campo vuoto");
    const password = document.getElementById("passSignup");
    password.setCustomValidity("campo vuoto");
    const  passrep = document.getElementById("reppassSignup");
    passrep.setCustomValidity("campo vuoto");
    // user con maiuscole minuscole e numeri
    regExpU = /^[A-Za-z0-9]{3,18}$/;
    // password con almeno un numero e almeno un carattere speciale
    regExpPass = /^(?=.*\d)(?=.*[^a-zA-Z0-9\s]).{8,18}$/;
    username.addEventListener("change", function(ev) { check(ev, regExpU); });
    password.addEventListener("change", function(ev) { check(ev, regExpPass, "password"); });
    passrep.addEventListener("change", function(ev) { check(ev, regExpPass, "password"); });
    let vett = [username,password,passrep];
    // per le istruzioni da far vedere a lato onhover utilizziamo l'evento "mouseover" e "mouseout"
    // i tre rispettivi div (user pass e pass rep) sono indicizzati da 0 ,1 ,2
    vett.forEach((el,idx) =>{
        el.addEventListener("mouseover", () => {toggle_in(idx);});
        el.addEventListener("mouseout", () => {toggle_out(idx);});
    });
}

// funzioni per mostrare e nascondere il messaggio
function toggle_in(idx){
    const el = document.querySelectorAll(".formatMessage")[idx];
    el.style.display = "block";
}

function toggle_out(idx){
    const el = document.querySelectorAll(".formatMessage")[idx];
    el.style.display = "none";
}


// funzione per colorare i bordi degli elementi giusti
function check(ev,regExp,type){
    const  el = document.getElementById(ev.target.id);
    // va controllata la validità
    if(!el.value.match(regExp)){
        el.style.border = "solid 1px red";
        el.setCustomValidity("Formato non valido");
    } else {
        el.style.border = "solid 1px green";
        el.setCustomValidity("");
    } 
    // se è una password si controllano tutte e due 
    if(type === "password"){
        const pass = document.getElementById("passSignup");
        const passrep = document.getElementById("reppassSignup");
        if(el.validity.valid && pass.value === passrep.value){
            pass.style.border = "solid 1px green";
            passrep.style.border = "solid 1px green";
            passrep.setCustomValidity("");
            pass.setCustomValidity("");
        } else if(pass.value === passrep.value){
            passrep.style.border = "solid 1px red"
            pass.style.border = "solid 1px red";
            pass.setCustomValidity("Le password coincidono ma non hanno un formato valido");
            passrep.setCustomValidity("Le password coincidono ma non hanno un formato valido");
        } else {
            passrep.style.border = "solid 1px red"
            pass.style.border = "solid 1px red";
            pass.setCustomValidity("Le password non coincidono");
            passrep.setCustomValidity("Le password non coincidono");
        }
    }

}
