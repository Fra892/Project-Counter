#include "shared.c"
#include <pthread.h>




// blocco define macro
#define PORT 4242           // numero della porta
#define NTHREADS 2          // numero di thread sempre presenti
#define NTHEMES 2           // numero dei temi previsti
#define NQUESTIONS 5        // numero delle domande previste
#define MAXPATHLEN 64       // grandezza massima del path prevista 
#define MAXDLEN 128         // massima lunghezza delle domande
#define MAXALEN 64          // massima lunghezza delle risposte
#define MAXNICKLEN 16       // massima lunghezza per il nickname
#define MAXTHEMELEN 64      // massima lunghezza per il tema 
#define ADDR "127.0.0.1"    // indirizzo
#define MAXBUFFER 2048      // buffer più grande allocabile


/* STRUTTURE DATI ----------------------------------------------------------*/
struct player_node{
    char nickname[MAXNICKLEN];
    int score;
    struct player_node* next;
    int done; // ci dice se ha completato il quiz 
};

// struttura dei temi globale 
struct theme_struct {
    // nome del tema caricato all'avvio dal main 
    char theme_name[MAXTHEMELEN];
    // classifica associata in ordine decrescente
    struct player_node* leaderboard;
    pthread_mutex_t leaderboard_mutex;
    // array di domande 
    char questions[NQUESTIONS][MAXDLEN];
    // array di risposte
    char answers[NQUESTIONS][MAXALEN];
};

// array di temi
struct theme_struct theme_array[NTHEMES];


struct thread_node {
    pthread_t id;                           // id del pthread
    int clsock;                             // socket assegnato
    int active;                             // è busy o meno
    int is_dynamic;                         // è parte del pool
    pthread_mutex_t mutex_condition;        /* mutex per cond_var                                          */
    pthread_cond_t NEW_CONN;                /*  (c'è una nuovo client assegnato dal padre)                */
    char* nickname;                         // nickname del giocatore che sta comunicando col thread (condiviso)
    struct thread_node* next;               // prossimo       
    int error;                              // per controllare il suo stato (NON CONDIVISO)
    pthread_mutex_t mutex_nickname;         // per il nickname (CONDIVISO)       
};

struct thread_node* thread_list;
pthread_mutex_t list_mutex;

/* ------------------------------------------------------------------------------------------------------------*/

/* FUNZIONI PER LA CREAZIONE DELLE STRUTTURE DATI PER IL GIOCO ------------------*/
int fill_a(char array[][MAXALEN], FILE* f){
    for(int i = 0; i < NQUESTIONS; i++){
        if(fgets(array[i], MAXALEN, f)){
            int len = strlen(array[i]) - 1;
            array[i][len] = '\0';
        } else {
            return 0;
        } 
    }
    return 1;
}

int fill_q(char array[][MAXDLEN], FILE* f){
    for(int i = 0; i < NQUESTIONS; i++){
        if(fgets(array[i], MAXDLEN, f)){
            int len = strlen(array[i]) - 1;
            array[i][len] = '\0';
        } else {
            return 0;
        } 
    }
    return 1;
}

int fill_name(char array[MAXTHEMELEN], FILE *f){
    if(fgets(array, MAXTHEMELEN, f)){
        int len = strlen(array) - 1;
        array[len] = '\0';
        return 1;
    } 
    return 0;

}
// funzione che inizializza la struttura dati globale
int create_theme_leaderboards(){
    for(int i = 0; i < NTHEMES; i++){
        struct theme_struct *st = &theme_array[i];
        char path_q[MAXPATHLEN];
        char path_a[MAXPATHLEN];
        FILE *fdq, *fda;
        // creazione dei path
        snprintf(path_q,MAXPATHLEN,"quiz/d%d.txt",i);
        snprintf(path_a,MAXPATHLEN,"quiz/r%d.txt",i);
        // apertura dei file
        fdq = fopen(path_q,"r");
        fda = fopen(path_a,"r");

        // get_name 

        // se non sono stati aperti errore
        if(!fdq || !fda){
            printf("errore apertura file");
            return 0;
        }
        if(!fill_name(st->theme_name,fdq))
            return 0;
        


        // se non riusciamo a riempire i campi errore
        if(!fill_q(st->questions,fdq) || !fill_a(st->answers,fda))
            return 0;
        // mettiamo
        st->leaderboard = NULL;
        pthread_mutex_init(&st->leaderboard_mutex,NULL);
    }
    return 1;
}
/*--------------------------------------------------------------------------------------------------------- */


/* FUNZIONI PER STAMPA MENU ------------------------------------------------------------------------------- */
void print_players(){
    int num_players = 0;
    // chiediamo la malloc per usare i puntatori e aggiungere controlli sulla disponibilità di memoria
    char *player_nicks = (char*)malloc(sizeof(char)*1024);
    char *old = player_nicks;
    pthread_mutex_lock(&list_mutex);
    for(struct thread_node* tn = thread_list; tn; tn = tn->next) {
        pthread_mutex_lock(&tn->mutex_nickname);
        if(!tn->nickname){ 
            pthread_mutex_unlock(&tn->mutex_nickname);
            continue;
        }
        player_nicks += sprintf(player_nicks,"- %s\n",tn->nickname);
        pthread_mutex_unlock(&tn->mutex_nickname);
        num_players++;
    }
    pthread_mutex_unlock(&list_mutex);
    if(!num_players){
        player_nicks += sprintf(player_nicks,"----\n");
    }
    printf("Partecipanti (%i)\n%s\n",num_players,old);
    free(old);
}

void print_finished_quiz(){
    for(int i = 0; i < NTHEMES; i++){
        int how_many = 0;
        printf("Quiz tema %d completato\n", i + 1);
        pthread_mutex_lock(&theme_array[i].leaderboard_mutex);
        for(struct player_node* pn = theme_array[i].leaderboard; pn; pn = pn->next){
            if(pn->done){
                printf("-%s\n",pn->nickname);
                how_many++;
            }
        }
        pthread_mutex_unlock(&theme_array[i].leaderboard_mutex);
        if(!how_many)
            printf("----\n");
        
        printf("\n");
    }

}

void print_leaderboard(){
    for(int i = 0; i < NTHEMES; i++){
        pthread_mutex_lock(&theme_array[i].leaderboard_mutex);
        struct player_node* pn = theme_array[i].leaderboard;
        printf("Punteggio tema %d\n", i + 1);
        if(!pn){
            printf("----\n");
        } else {
            while(pn){
                printf("-%s %d\n", pn->nickname, pn->score);
                pn = pn->next;
            }
            
        }
        pthread_mutex_unlock(&theme_array[i].leaderboard_mutex);
        printf("\n");    
    }
}

void print_theme(){
    printf("Temi:\n");
    for(int i = 0; i < NTHEMES; i++)
        printf("%d - %s\n", i + 1, theme_array[i].theme_name);
}

// FUNZIONE che pulisce la schermata
void clear_screen(){
    system("clear");
}

// FUNZIONE che stampa l'interfaccia
void print_menu(){
    clear_screen();
    printf("Trivia Quiz\n");
    printf("+++++++++++++++++\n");
    print_theme();
    printf("++++++++++++++++++\n\n");
    print_leaderboard();
    print_finished_quiz();
    print_players();
}
/*------------------------------------------------------------------------------------------------*/


/* FUNZIONI PER CREAZIONE MESSAGGI ------------------------------------------------------*/
// leaderboard in chiaro (pun avanza per concatenazione buffer alla base del mesasggio)
char* load_leaderboard(char* buffer){
    char *pun = buffer;
    for(int i = 0; i < NTHEMES; i++){
        pthread_mutex_lock(&theme_array[i].leaderboard_mutex);
        struct player_node* pn = theme_array[i].leaderboard;
        pun += sprintf(pun, "Punteggio tema %d\n", i + 1);
        if(!pn){
            pun += sprintf(pun, "----\n");
        } else {
            while(pn){
                pun += sprintf(pun,"-%s %d\n", pn->nickname, pn->score);
                pn = pn->next;
            }
            
        }
        pthread_mutex_unlock(&theme_array[i].leaderboard_mutex);
        pun += sprintf(pun, "\n");
    }
    return pun;
}

// temi compressi
char* load_theme(char* buffer){
    char *pun = buffer;
    for(int i = 0; i < NTHEMES; i++){
        pun += sprintf(pun, "%s-", theme_array[i].theme_name);
    }
    return pun;
}

/*-----------------------------------------------------------------------------------------*/





/* FUNZIONI PER GESTIONE LEADERBOARD ------------------------------------------------------*/
// funzione per inserire il player nella lista del tema prima di fare le domande
int insert_leaderboard(int idx_tema, const char* nickname){
    if(idx_tema < 0 || idx_tema >= NTHEMES) return 0;
    // lock sulla leaderboard
    pthread_mutex_lock(&theme_array[idx_tema].leaderboard_mutex);
    struct player_node** pn = &theme_array[idx_tema].leaderboard;
    struct player_node* new_node = (struct player_node*)malloc(sizeof(struct player_node));
    // con la memset settiamo automaticamente lo score a 0 e il next a NULL e done a zero
    memset((void*)new_node, 0, sizeof(struct player_node));
    strcpy(new_node->nickname, nickname);
    // inserimento in coda
    while(*pn)
        pn = &(*pn)->next;
    *pn = new_node;
    pthread_mutex_unlock(&theme_array[idx_tema].leaderboard_mutex);
    return 1;
}

// Aggiornamento della leaderboard (done || point)
int update_leaderboard(int idx_tema, const char* nickname, int done, int point){
    if(idx_tema < 0 || idx_tema >= NTHEMES) return 0;
    struct theme_struct* ts = &theme_array[idx_tema];
    pthread_mutex_lock(&ts->leaderboard_mutex);
    struct player_node** pn;
    // ricerca nodo 
    for(pn = &ts->leaderboard; *pn && strcmp((*pn)->nickname,nickname); pn = &(*pn)->next);
    // (DEBUG)
    if(!*pn){
        pthread_mutex_unlock(&ts->leaderboard_mutex);
        return 0;
    }
    //set di done
    (*pn)->done = done;
    // se il punteggio non cambia usciamo
    if(!point){
        pthread_mutex_unlock(&ts->leaderboard_mutex);
        return 1;
    }
    // sennò estraiamo e reinseriamo nella posizione corretta
    struct player_node* to_reinsert = *pn;
    to_reinsert->score++;
    // estrazione
    (*pn) = (*pn)->next;
    // ricerca posizione
    for(pn = &ts->leaderboard; *pn && to_reinsert->score < (*pn)->score; pn = &(*pn)->next);
    // inserimento
    to_reinsert->next = *pn;
    *pn = to_reinsert;

    pthread_mutex_unlock(&ts->leaderboard_mutex);
    return 1;
}


// funzione per eliminare un player dalla leaderboard il mutex è stato già preso
void delete_player(struct player_node** pn, const char* nickname){
    while(*pn && strcmp((*pn)->nickname,nickname))
        pn = &(*pn)->next;
    if(*pn){
        struct player_node* todel = *pn;
        *pn = (*pn)->next;
        free(todel);
    }
}

// funzione che distrugge tutte le tracce di un utente dalle leaderboard
void destroy_info_from_leaderboard(const char* nickname){
    for(int i = 0; i < NTHEMES; i++){
        pthread_mutex_lock(&theme_array[i].leaderboard_mutex);
        delete_player(&theme_array[i].leaderboard, nickname);
        pthread_mutex_unlock(&theme_array[i].leaderboard_mutex);
    }
}

/*--------------------------------------------------------------------------------------------------*/


/* FUNZIONE PER LA GESTIONE DEI THREADS -------------------------------------------------------------*/
// Prototipo 1(alloca strutture dati per i thread e se è dinamico lo fa partire subito)
void create_and_add_thread(int cl_sock, int is_dynamic);

// crea i thread statici (in fondo alla lista)
void create_thread_pool() {
    // creiamo la thread pool
    pthread_mutex_init(&list_mutex,NULL);
    thread_list = NULL;
    for (int i = 0; i < NTHREADS; i++) {
        create_and_add_thread(-1, 0);
    }
}
// funzione con cui il padre cerca un thread libero a cui assegnare la connessione
int assign_to_free_thread(int client_sock) {
    pthread_mutex_lock(&list_mutex);
    struct thread_node* current = thread_list;
    while (current) {
        // per controllare la variabile condition dobbiamo prendere il mutex
        pthread_mutex_lock(&current->mutex_condition);
        // se non è attivo allora gli assegnamo il socket (per sicurezza non assegnamo ai dinamici (dovrebbe già essere assegnato))
        if (!current->active && !current->is_dynamic) {
            current->clsock = client_sock;
            // lo attiviamo
            current->active = 1;
            // segnaliamo che ora ha una connessione
            pthread_cond_signal(&current->NEW_CONN);
            pthread_mutex_unlock(&current->mutex_condition);
            // togliamo il mutex sulla condition
            pthread_mutex_unlock(&list_mutex);
            return 1; 
        }
        pthread_mutex_unlock(&current->mutex_condition);
        current = current->next;
    }
    pthread_mutex_unlock(&list_mutex);
    return 0; // Nessun thread libero
}

// funzione per controllare se il nickname è corretto
int check_nickname(const char* nickname, struct thread_node* self){
    pthread_mutex_lock(&list_mutex);
    struct thread_node* td = thread_list;
    while(td){
        pthread_mutex_lock(&td->mutex_nickname);
        // trovato ?
        if(td->nickname && !strcmp(td->nickname, nickname)){
            pthread_mutex_unlock(&td->mutex_nickname);    
            break;
        }
        pthread_mutex_unlock(&td->mutex_nickname);
        td = td->next;
    }
    // se non è stato trovato aggiorniamo il nickname
    if(!td){
        // consistenza nella lettura e scrittura della variabile
        pthread_mutex_lock(&self->mutex_nickname);
        self->nickname = strdup(nickname);
        pthread_mutex_unlock(&self->mutex_nickname);
    }
    pthread_mutex_unlock(&list_mutex);
    return (!td)? 1 : 0;
}

// elimina dalla lista dei thread il thread dinamico che ha finito di gestire la connessione
int delete_dynamic_thread(struct thread_node* self){
    struct thread_node** p;
    pthread_mutex_lock(&list_mutex);

    // troviamo il thread
    for(p = &thread_list; *p != self; p = &(*p)->next);
    // (DEBUG? non si eliminano thread dinamici o thread non esistenti)
    if(!*p || !(*p)->is_dynamic){
        pthread_mutex_unlock(&list_mutex);
        perror("Errore nel codice");
        return 0;
    }
    *p = (*p)->next;
    // distruzione della struttura dati e dei vari strumenti per memoria condivisa
    pthread_mutex_destroy(&self->mutex_condition);
    pthread_mutex_destroy(&self->mutex_nickname);
    pthread_cond_destroy(&self->NEW_CONN);
    free(self);
    pthread_mutex_unlock(&list_mutex);
    return 1;
    
}
// MAIN THREAD FUN
void* thread_function(void* arg) {
    struct thread_node* self = (struct thread_node*)arg;
    do {
        int sock;
        char* buffer = (char*)malloc(sizeof(char) * MAXBUFFER), *pun;
        char* nickname;
        uint8_t type;
        int theme_index;
        int counter;

        // ALLOCAZIONE BUFFER ?
        if(!buffer){
            self->error = NOT_ENOUGH_SPACE;
            goto end_game;
        }
            
        
        // il thread prima di partire deve controllare che il padre gli abbia dato una connessione
        pthread_mutex_lock(&self->mutex_condition);
        while (!self->active)
            pthread_cond_wait(&self->NEW_CONN, &self->mutex_condition);
        sock = self->clsock;
        pthread_mutex_unlock(&self->mutex_condition);
        do {
            if((self->error = recv_just_header(&type, sock)) != SUCCESS)
                goto end_game;


            self->error = (type != REQUEST_LEADERBOARD && type != REQUEST_NICKNAME && type != ENDQUIZ)? TYPE_INCONSISTENCY: self->error;
            if(self->error != SUCCESS)
                goto end_game;

            if(type == REQUEST_LEADERBOARD){
                pun = load_leaderboard(buffer);
                if(pun == buffer)
                    goto end_game;

                if((self->error = send_big_data(buffer, LEADERBOARD, sock)) != SUCCESS)
                    goto end_game;
                continue;
            }

            if(type == ENDQUIZ)
                goto end_game;
            
            if((self->error = recv_just_body(buffer, sock)) != SUCCESS)
                goto end_game;
            // controllo e scrittura atomica del nickname
            if(check_nickname(buffer,self)){
                if((self->error = send_just_header(ACK, sock) != SUCCESS))
                    goto end_game;
                break;
            } 

            if((self->error = send_just_header(NAK, sock)) != SUCCESS)
                goto end_game;         

        } while(1);
        nickname = strdup(buffer);


        print_menu();
        pun = load_theme(buffer);
        if(pun == buffer)
            goto end_game;

        if((self->error = send_data(buffer, OPTIONS, sock)) != SUCCESS)
            goto end_game;
    
        counter = NTHEMES;
        do {

            do{

                if((self->error = recv_just_header(&type, sock)) != SUCCESS)
                    goto end_game;

                self->error = (type != CHOICE && type != REQUEST_LEADERBOARD && type != ENDQUIZ)? TYPE_INCONSISTENCY: self->error;

                if(self->error != SUCCESS)
                    goto end_game;

                if(type == REQUEST_LEADERBOARD){
                    pun = load_leaderboard(buffer);
                    if(pun == buffer)
                        goto end_game;
                    if((self->error = send_big_data(buffer, LEADERBOARD, sock)) != SUCCESS)
                        goto end_game;
                    continue;
                }

                if(type == ENDQUIZ)
                    goto end_game;
                if((self->error=recv_just_body(buffer,sock))!= SUCCESS)
                    goto end_game;
                theme_index = atoi(buffer) - 1;  
                break;  

            } while(1);  

            if(!insert_leaderboard(theme_index, nickname))
                goto end_game;

            for(int i = 0; i < NQUESTIONS; i++){
                int done = 0, point = 0;
                strcpy(buffer,theme_array[theme_index].questions[i]);
                if((self->error = send_data(buffer, QUESTION, sock)) != SUCCESS)
                    goto end_game;
                if((self->error = recv_just_header(&type, sock)) != SUCCESS)
                    goto end_game;

                self->error = (type != ANSWER && type != REQUEST_LEADERBOARD && type != ENDQUIZ && type != NAK)? TYPE_INCONSISTENCY: self->error;
                if(self->error != SUCCESS)
                    goto end_game;


                if(type == REQUEST_LEADERBOARD){
                    pun = load_leaderboard(buffer);
                    if(pun == buffer)
                        goto end_game;
                    if((self->error = send_big_data(buffer, LEADERBOARD, sock)) != SUCCESS)
                        goto end_game;
                    i--;
                    continue;
                }

                if(type == ENDQUIZ)
                    goto end_game;

                if(type == ANSWER){
                    if((self->error = recv_just_body(buffer, sock)) != SUCCESS)
                        goto end_game;
                    point = !strcmp(buffer, theme_array[theme_index].answers[i]);
                } 
                done = (i == NQUESTIONS - 1);

                if(point || done){
                    if(!update_leaderboard(theme_index, nickname, done, point))
                        goto end_game;
                    print_menu();
                }

            }

            if(!--counter)
                break;
        } while(1);

        do {
            if((self->error = recv_just_header(&type, sock)) != SUCCESS)
                goto end_game;

            self->error = (type != REQUEST_LEADERBOARD && type != ENDQUIZ)? TYPE_INCONSISTENCY: self->error;
            if(self->error != SUCCESS)
                goto end_game;

            if(type == REQUEST_LEADERBOARD){                    
                pun = load_leaderboard(buffer);
                if(pun == buffer)
                    goto end_game;
                if((self->error = send_big_data(buffer, LEADERBOARD, sock)) != SUCCESS)
                    goto end_game;
                continue;
            }
            if(type == ENDQUIZ)
                goto end_game;
        } while(1);

        // in endgame ci finiamo se abbiamo finito il gioco (ovvero il giocatore ha fatto endquiz e dunque a un certo punto si è disconnesso )
        // oppure per un errore 
end_game:
        // eliminazione del nickname 
        pthread_mutex_lock(&self->mutex_nickname);
        destroy_info_from_leaderboard(self->nickname);
        free(self->nickname);
        self->nickname = NULL;
        pthread_mutex_unlock(&self->mutex_nickname);
    
        // eliminazione della comunicazione
        pthread_mutex_lock(&self->mutex_condition);
        self->clsock = -1;
        self->active = 0;
        pthread_mutex_unlock(&self->mutex_condition);


        free(buffer);
        free(nickname);

        // aggiornamento interfaccia
        print_menu();
        
        int* error = (int*)malloc(sizeof(int));
        *error = self->error;
        // print dell'errore
        if(*error != SUCCESS)
            show_error(*error);



        // se era dinamico dobbiamo distruggere la struttura dati associata e toglierla dalla lista 
        if(self->is_dynamic) {
            delete_dynamic_thread(self);
            if(*error != SUCCESS)
                pthread_exit((void*)error);
            else 
                pthread_exit(NULL);
        }
    } while(1);

    return NULL;
}
/* ----------------------------------------------------------------------------------*/

/* IMPL DEL PROTOTIPO 1 -------------------------------------------------------------*/
void create_and_add_thread(int client_sock, int is_dynamic) {
    struct thread_node* node = (struct thread_node*)malloc(sizeof(struct thread_node));
    node->clsock = client_sock;
    // se è dinamico è già pronto sennò sta aspettando che venga passato il socket
    node->active = is_dynamic;
    // gli diciamo se si dovrà distruggere
    node->is_dynamic = is_dynamic;
    // settiamo il nick a null
    node->nickname = NULL;
    // settiamo mutex e conditions
    pthread_mutex_init(&node->mutex_condition, NULL);
    pthread_mutex_init(&node->mutex_nickname, NULL);
    pthread_cond_init(&node->NEW_CONN, NULL);

    // se è dinamico vuol dire che c'è già una connessione disponibile 
    if(is_dynamic)
        pthread_cond_signal(&node->NEW_CONN);
    // aggiungiamo alla lista in testa così sarà più veloce da rimuovere
    pthread_mutex_lock(&list_mutex);
    node->next = thread_list;
    thread_list = node;
    pthread_mutex_unlock(&list_mutex);
    // facciamo partire il thread
    pthread_create(&node->id, NULL, thread_function, node);
}
/* ----------------------------------------------------------------------------------*/

// ENTRY POINT ----------------------------------------------------------------------
int main(int argc, char** argv) {
    int server_sock, client_sock;
    struct sockaddr_in addr, cli_addr;

    // creazione strutture dati per il gioco
    create_theme_leaderboards();  
    create_thread_pool();
    print_menu();

    // init master socket
    server_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (server_sock < 0) {
        perror("Errore nella creazione del socket:");
        exit(EXIT_FAILURE);
    }
    // set sockaddr str
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    inet_pton(AF_INET, ADDR, &addr.sin_addr);

    // bind sock a addr
    if (bind(server_sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("Errore nel bind all'indirizzo:");
        exit(EXIT_FAILURE);
    }

    // listen per TCP connections
    if(listen(server_sock, 10) < 0){
        perror("Errore nella listen:");
        exit(EXIT_FAILURE);
    }
    
    while (1) {
        
        socklen_t addr_len = sizeof(cli_addr);
        // accept bloccante
        client_sock = accept(server_sock, (struct sockaddr*)&cli_addr, &addr_len);
        if (client_sock < 0) 
            continue;
        
        // se non ci sono thread liberi ne creiamo uno
        if (!assign_to_free_thread(client_sock)) 
            create_and_add_thread(client_sock, 1);
    }
    // chiusura del server

    close(server_sock);
    return 0;
}
