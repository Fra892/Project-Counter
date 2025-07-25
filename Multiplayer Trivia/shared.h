#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <unistd.h> 
#include <errno.h>



// tutti i tipi di messaggi
enum type_message {
    OPTIONS,                // opzioni per i temi
    CHOICE,                 // scelta del client
    QUESTION,               // richiesta domanda
    ANSWER,                 // risposta del client
    ACK,                    // ok
    NAK,                    // non ok
    REQUEST_LEADERBOARD,    // richiesta leaderboard del client
    LEADERBOARD,            // leaderboard mandata dal server
    REQUEST_NICKNAME,       // richiesta del nickname
    ENDQUIZ,                // fine del quiz
};
// tutti i tipi di errori generabili
enum outcome {
    SUCCESS,              // successo
    MISSING_BYTES,        // frammentazione per messaggi piccoli
    TYPE_INCONSISTENCY,   // errore del protocllo
    DISCONNECTION,        // disconnessione
    ABRUPT_DISCONNECTION_R, // disconnnessione brusca su recv
    ABRUPT_DISCONNECTION_W, // disconnessione brusca su send
    BROKEN_PIPE,          // il client non può scrivere sul buffer di output perchè il server è morto 
    GENERIC_ERROR,        // -1 
    INVALID_RETURN,       // DEBUG 
    BUG_DETECTED,         // DEBUG 
    NOT_ENOUGH_SPACE,     // MALLOC WENT WRONG (per buffer grande nei thread)
};

// prototipi delle funzioni
int send_data(char *buf, uint8_t type, int sock);

int recv_data(char* buf, uint8_t type, int sock);

int send_big_data(char* buf, uint8_t type, int sock);

int recv_big_data(char* buf, uint8_t type, int sock);

int send_just_header(uint8_t type, int sock);

int recv_just_header(uint8_t* type, int sock);

int recv_just_body(char* buf, int sock);

int get_error_send(int ret);
int get_error_recv(int ret);

void show_error(int outcome);

