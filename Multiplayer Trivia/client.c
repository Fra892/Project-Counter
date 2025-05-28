#include "shared.c"


/* blocco define macro*/
#define PORT 4242           // porta a cui il server offre il servizio
#define ADDR "127.0.0.1"    // indirizzo
#define MAXNICKLEN 16       // lunghezza massima del nickname
#define MAXSIZEBUFIN 1024   // grandezza buffer di ricezione
#define MAXSIZEBUFOUT 512   // grandezza buffer di invio e gestione io
#define NTHEMES 2           // numero di temi
#define MAXTHEMELEN 64      // lunghezza massima del nome dei temi
#define MAXSTRLEN 64        // lunghezza massima per l'input
#define NQUESTIONS 5        // numero di domande



/* STRUTTURE PER E GLOBALS PER IL CLIENT -----------------------------------------------------*/
struct theme{
    char theme_name[MAXTHEMELEN];
    int done; // per validazione client
};

struct theme theme_array[NTHEMES];

int error = SUCCESS; // per tenere traccia dello stato 
/*--------------------------------------------------------------------------------------------*/




/* FUNZIONI PER LE STRUTTURE DATI ------------------------------------------------------------*/
void fill_themes(char* buf_in){
    strcpy(theme_array[0].theme_name,strtok(buf_in,"-"));
    for(int i = 1; i < NTHEMES; i++){
            strcpy(theme_array[i].theme_name,strtok(NULL,"-"));
    }
}
/*---------------------------------------------------------------------------------------------*/


/* FUNZIONI PER STAMPARE I MENU ---------------------------------------------------------------*/

void clear_screen(){
    system("clear");
}

void print_start_menu(){
    clear_screen();
    printf("Trivia Quiz\n");
    printf("+++++++++++++++++++++++\n");
    printf("Menù\n");
    printf("1 - Comincia una nuova sessione di Trivia\n");
    printf("2 - Esci\n");
    printf("+++++++++++++++++++++++\n");
    printf("La tua scelta: ");
}

void print_remainder(){
    clear_screen();
    printf("Trivia Quiz\n");
    printf("+++++++++++++++++++++\n");
    printf("!! Durante la sessione di Trivia puoi utilizzare i seguenti comandi !!\n");
    printf("1) show score (per visualizzare la classifica di tutti i giocatori connessi)\n");
    printf("2) endquiz    (per terminare la sessione di trivia)\n");
    printf("+++++++++++++++++++++\n");
    printf("premi \'q\' per continuare: ");

}

void print_nickname_menu(){
    clear_screen();
    printf("Trivia Quiz\n");
    printf("+++++++++++++++++++++\n");
    printf("Inserisci il tuo nickname(univoco MAX 16 caratteri):\n");
}

void print_theme_menu(){
    clear_screen();
    printf("Quiz Disponibili \n");
    printf("++++++++++++++++++++\n");
    for(int i = 0; i < NTHEMES; i++){
        if(!theme_array[i].done)
            printf("%i - %s\n",i + 1,theme_array[i].theme_name);

    }
    printf("++++++++++++++++++++\n");
    printf("La tua scelta: ");

}

void print_question_game(const char* question, const char* theme_name){
    clear_screen();
    printf("Quiz - %s\n",theme_name);
    printf("++++++++++++++++++++++\n");
    printf("%s\n\n",question);
    printf("Risposta: ");
}

void retry_input(){
    printf("\n !! input non valido !!\n");
    printf("prova di nuovo: ");
}
void retry_nickname(){
    printf("\n !! nickname già in uso !! \n");
    printf("prova con un altro nickname: ");

}

void print_ending(){
    clear_screen();
    printf("Trivia Quiz\n");
    printf("+++++++++++++++++++++\n");
    printf("Hai completato tutti i temi: \n");
    printf("1) Visualizza la classifica con il comando \'show score\'\n");
    printf("2) Termina la session con il comando \'endquiz\'\n");
    printf("++++++++++++++++++++\n");
    printf("comando: ");

}
/*---------------------------------------------------------------------------------------------*/



/* FUZIONI PER GLI LO STDIN -------------------------------------------------------------------*/
int get_input(char* buffer, int dim){
    if(fgets(buffer, dim, stdin)){
        int got = strlen(buffer);
        if(got > 0 && buffer[got - 1] == '\n'){
            buffer[got - 1] = '\0';
            return 1;
        } else {
            // c'è il rischio che alla prossima fget il buffer di input sia sporco
            int c;
            while( (c = getchar()) != '\n' && c != EOF );
            return 0;
            // se è più grande del previsto sicuramente è sbagliata
        }
    }
    return 0;
}
/*---------------------------------------------------------------------------------------------*/




/* FUNZIONE PER LA RICHIESTA DELLA LEADERBOARD ------------------------------------------------*/
int request_leaderboard(char* buf,int sock){
    if((error = send_just_header(REQUEST_LEADERBOARD, sock)) != SUCCESS)
        return error;
    if((error = recv_big_data(buf, LEADERBOARD, sock)) != SUCCESS)
        return error;
    clear_screen();
    printf("Trivia Quiz Leaderboard\n");
    printf("+++++++++++++++++++\n");
    printf("%s",buf);
    printf("+++++++++++++++++++\n");
    printf("premi \'q\' per continuare: ");
    return SUCCESS;
}
/* --------------------------------------------------------------------------------------------*/

/* FUNZIONE per la visualizzazione della leaderboard e del reminder ---------------------------*/
void waiting(){
    char ch[3];
    do {
        if(!get_input(ch,3))
            continue;
    } while(strcmp(ch,"q"));
    clear_screen();
}
/*--------------------------------------------------------------------------------------------*/
// @ENTRY POINT
int main(int argc, char** argv){
    int my_sock = -1, choice, counter;
    struct sockaddr_in serv_addr;
    char buf_in[MAXSIZEBUFIN]; 
    char buf_out[MAXSIZEBUFOUT];
    // set della struct sockaddr
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);
    inet_pton(AF_INET, ADDR, &serv_addr.sin_addr);


    print_remainder();
    waiting();

start_game:
    print_start_menu();
    // blocco iniziale
    do {
        if(!get_input(buf_out, 3)){
            retry_input();
            continue;
        }    
        choice = atoi(buf_out);
        if(choice == 1 || choice == 2)
            break;
        retry_input();
    } while(1);


    if(choice == 2)
        goto end_game;

    // init socket
    my_sock = socket(AF_INET, SOCK_STREAM, 0);
    if(my_sock < 0){
        perror("Errore inizializzazione socket ");
        exit(EXIT_FAILURE);
    }

    // connect
    if(connect(my_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1){
        perror("Errore di connessione");
        exit(EXIT_FAILURE);
    }

    print_nickname_menu();
    // blocco per la scelta del nickname
    while(1){
        uint8_t type;
        // controllo input
        if(!get_input(buf_out,MAXNICKLEN + 2)){
            retry_input();
            continue;
        }
        // richiesta classifica
        if(!strcmp(buf_out,"show score")){
            if(request_leaderboard(buf_in, my_sock) != SUCCESS)
                goto end_game;
            waiting();
            continue;
        }
        // fine del quiz
        if(!strcmp(buf_out,"endquiz")){
            if((error = send_just_header(ENDQUIZ, my_sock)) != SUCCESS)
                goto end_game;
            close(my_sock);
            goto start_game;
        }
        // richiesta
        if((error = send_data(buf_out, REQUEST_NICKNAME, my_sock)) != SUCCESS)
            goto end_game;

        // esito
        if((error = recv_just_header(&type, my_sock)) != SUCCESS)
            goto end_game;

        // protocol error ?
        error = (type != ACK && type != NAK)? TYPE_INCONSISTENCY: error;
        if(error != SUCCESS)
            goto end_game;

        // nick accettato ?
        if(type == ACK)
            break;
        retry_nickname();

        
    }
    // prendiamo i temi
    if((error = recv_data(buf_in, OPTIONS, my_sock)) != SUCCESS)
        goto end_game;
    // filliamo la struttura dati
    fill_themes(buf_in);

    // inizializzazione 
    for(int i = 0; i < NTHEMES; i++)
        theme_array[i].done = 0;
    

    // tiene traccia dei temi svolti
    counter = NTHEMES;

    do{
        print_theme_menu();
        // blocco scelta tema
        do {
            
            if(!get_input(buf_out, strlen("show score") + 2)){
                retry_input();
                continue;
            }
                
            
            if(!strcmp(buf_out, "show score")){
                if(request_leaderboard(buf_in, my_sock) != SUCCESS)
                    goto end_game;
                waiting();
                print_theme_menu();
                continue;
            }
                    
            if(!strcmp(buf_out,"endquiz")){
                if((error = send_just_header(ENDQUIZ, my_sock)) != SUCCESS)
                    goto end_game;
                close(my_sock);
                goto start_game;
            }
            // convesersione ad indice e controllo della validità
            choice = atoi(buf_out) - 1;
            if(choice >= 0 && choice < NTHEMES && !theme_array[choice].done){
                if((error = send_data(buf_out, CHOICE, my_sock)) != SUCCESS)
                    goto end_game;
                break;
            }
            // comando non riconosciuto o input non valido
            retry_input();
        } while(1);

        for(int i = 0; i < NQUESTIONS; i++){
            if((error = recv_data(buf_in, QUESTION, my_sock)) != SUCCESS)
                goto end_game;
            
            print_question_game(buf_in, theme_array[choice].theme_name);
            // MAXSTRLEN > MAXALEN
            if(!get_input(buf_out,MAXSTRLEN)){
                if((error = send_just_header(NAK, my_sock)) != SUCCESS)
                    goto end_game;
                continue;
            } 


            if(!strcmp(buf_out,"show score")){
                if(request_leaderboard(buf_in, my_sock) != SUCCESS)
                    goto end_game;      
                i--;
                waiting();
                continue;
            }
            
            if(!strcmp(buf_out,"endquiz")){
                if((error = send_just_header(ENDQUIZ, my_sock)) != SUCCESS)
                    goto end_game;
                close(my_sock);
                goto start_game;
            }
            
            if((error = send_data(buf_out, ANSWER, my_sock)) != SUCCESS)
                goto end_game;

        }   
        // completato
        theme_array[choice].done = 1;

        // temi finiti
        if(!--counter)
            break;
    } while(1);

    print_ending();
    do {
        // show score è il comando più lungo
        if(!get_input(buf_out,strlen("show score")+2)){
            retry_input();
            continue;
        }

        if(!strcmp(buf_out,"show score")){
            if(request_leaderboard(buf_in, my_sock) != SUCCESS)
                goto end_game;
            waiting();
            print_ending();
            continue;
        }
        if(!strcmp(buf_out,"endquiz")){
            if((error = send_just_header(ENDQUIZ, my_sock)) != SUCCESS)
                goto end_game;
            close(my_sock);
            goto start_game;
        }
        retry_input();
    } while(1);

    // blocco endgame
end_game:
    // controllo per sicurezza
    if(my_sock >= 0)
        close(my_sock);
    // resoconto dell'errore
    if(error != SUCCESS){
        show_error(error);
        exit(EXIT_FAILURE);
    }
    return 0;
}
