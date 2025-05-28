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
    OPTIONS,
    CHOICE,
    QUESTION,
    ANSWER,
    ACK,
    NAK,
    REQUEST_LEADERBOARD,
    LEADERBOARD,
    REQUEST_NICKNAME,
    ENDQUIZ,
};
// tutti i tipi di errori generabili
enum outcome {
    SUCCESS,
    MISSING_BYTES,
    TYPE_INCONSISTENCY,
    DISCONNECTION,
    ABRUPT_DISCONNECTION,
    GENERIC_ERROR,
    INVALID_RETURN,     // DEBUG (for send and recv primitives)
    BUG_DETECTED,       // DEBUG (for coding errors)
    NOT_ENOUGH_SPACE,   // MALLOC WENT WRONG (per buffer grande nei thread)
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

