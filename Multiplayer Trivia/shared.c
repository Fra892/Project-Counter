#include "shared.h"


/* 1) I MESSAGGI GROSSI (con grosso body) vengono trattati differentemente
        1.1) per via della frammentazione probabile facciamo un ciclo in attesa che si ricevano/mandino tutti i byte
        1.2) le recv erronee vengono analizzate in base a l'errore che potrebbe risultare temporaneo (in questo caso si continua a ricevere)
    2) IL PROT1OCOLLO SI ARTICOLA in 3 SEND e RECV
        - HEADER (tipo e lunghezza) necessario
        - BODY   (body)             opzionale
    3) LA VALIDITA DEL GIOCO e del protocollo è implementato CON l'header (tipo)
    4) LE RECV (one way) si accetta solo un tipo di dato con un certo header (seguite da un body) controllano la validità del protocollo

    5) L'HEADER è mandato in binary mentre il BODY è sempre una stringa manipolabile dal ricevente(formato testo)
*/

/* FUNZIONI PER MANDARE DATI --------------------------------------------------------------------*/
int send_data(char *buf, uint8_t type, int sock){
    uint32_t len = strlen(buf)+1, len_to_send;
    int ret = send(sock, &type, sizeof(uint8_t), MSG_NOSIGNAL);
    if(ret < sizeof(uint8_t))
        return get_error_send(ret);
    
    len_to_send = htonl(len);
    ret = send(sock, &len_to_send, sizeof(uint32_t), MSG_NOSIGNAL);
    if(ret < sizeof(uint32_t))
        return get_error_send(ret);
    
    ret = send(sock, buf, len, MSG_NOSIGNAL);
    if(ret < len)
        return get_error_send(ret);
    
    return SUCCESS;
}

int send_big_data(char* buf, uint8_t type, int sock){
    uint32_t len = strlen(buf) + 1, len_to_send, sent = 0;
    int ret = send(sock, &type, sizeof(uint8_t), MSG_NOSIGNAL);
    if(ret < sizeof(uint8_t))
        return get_error_send(ret);
    
    len_to_send = htonl(len);
    ret = send(sock, &len_to_send, sizeof(uint32_t), MSG_NOSIGNAL);

    if(ret < sizeof(uint32_t))
        return get_error_send(ret);
    
    do {
        ret = send(sock, &buf[sent], len - sent, MSG_NOSIGNAL);
        if(ret == -1) return get_error_send(ret);
        sent += ret;
    } while(sent < len);
    return SUCCESS;
}
/* -------------------------------------------------------------------------------------------*/
/* FUNZIONI PER RICEVERE DATI CON HEADER -----------------------------------*/
int recv_data(char* buf, uint8_t type, int sock){
    uint32_t len;
    uint8_t received_type;
    int ret = recv(sock, &received_type, sizeof(uint8_t), 0);
    if(ret < sizeof(uint8_t))
        return get_error_recv(ret);
    
    if(type != received_type) return TYPE_INCONSISTENCY;
    ret = recv(sock, &len, sizeof(uint32_t), 0);
    if(ret < sizeof(uint32_t))
        return get_error_recv(ret);
    
    len = ntohl(len);
    ret = recv(sock, buf, len, 0);
    if(ret < len)
        return get_error_recv(ret);
    
    return SUCCESS; 
}
int recv_big_data(char* buf, uint8_t type, int sock){
    uint32_t len, received = 0;
    uint8_t received_type;
    int ret = recv(sock, &received_type, sizeof(uint8_t), 0);
    if(ret < sizeof(uint8_t))
        return get_error_recv(ret);
    
    if(type != received_type) return TYPE_INCONSISTENCY;
    ret = recv(sock, &len, sizeof(uint32_t), 0);
    if(ret < sizeof(uint32_t))
        return get_error_recv(ret);
    
    len = ntohl(len);
    do {
        ret = recv(sock, &buf[received], len - received, 0);
        if(ret == 0 || (ret == -1 && errno != EAGAIN  && errno != EINTR)) return get_error_recv(ret); 
        received += ret;
    } while(received <  len);
    return SUCCESS;
}
/* ---------------------------------------------------------------------------*/
/* FUNZIONI PER RICEVERE SOLO I BODY -----------------------------------------*/
int recv_just_body(char *buf, int sock){
    uint32_t len;
    int ret = recv(sock, &len, sizeof(uint32_t), 0);
    if(ret < sizeof(uint32_t))
        return get_error_recv(ret);
    
    len = ntohl(len);
    ret = recv(sock, buf, len , 0);
    if(ret < len)
        return get_error_recv(ret);
    
    return SUCCESS; 
}

int recv_just_big_body(char *buf, int sock){
    int received = 0;
    uint32_t len;
    int ret = recv(sock, &len, sizeof(uint32_t),0);
    if(ret < sizeof(uint32_t))
        return get_error_recv(ret);
    
    len = ntohl(len);
    do {
        ret = recv(sock, &buf[received], len - received, 0);
        if(ret == 0 || (ret == -1 && errno != EAGAIN  && errno != EINTR)) return get_error_recv(ret); 
    } while(received <  len);
    return SUCCESS;
}
/* --------------------------------------------------------------------------------*/

/* FUNZIONI PER MANDARE SOLO L'HEADER ---------------------------------------------*/
int recv_just_header(uint8_t* type, int sock){
    int ret = recv(sock, type, sizeof(uint8_t), 0);
    if(ret < sizeof(uint8_t))
        return get_error_recv(ret);
    
    return SUCCESS;
}

int send_just_header(uint8_t type, int sock){
    int ret = send(sock, &type, sizeof(uint8_t),MSG_NOSIGNAL);
    if(ret < sizeof(uint8_t))
        return get_error_send(ret);
    
    return SUCCESS;
}
/* -------------------------------------------------------------------------------*/


/* FUNZIONI PER DETERMINARE L'ERRORE  -------------------------------------------- */
int get_error_recv(int ret){
    if(ret > 0)
        return MISSING_BYTES;
    if(ret == 0)
        return DISCONNECTION;
    if(ret == -1){
        if(errno == ECONNRESET)
            return ABRUPT_DISCONNECTION_R;
        return GENERIC_ERROR;
    }
    return INVALID_RETURN;
}
int get_error_send(int ret){
    if(ret > 0)
        return MISSING_BYTES;
    if(ret == -1){
        if(errno == EPIPE)
            return BROKEN_PIPE;
        if(errno == ECONNRESET)
            return ABRUPT_DISCONNECTION_W;
        return GENERIC_ERROR;
    }
    return INVALID_RETURN;
}
/*-------------------------------------------------------------------------------- */

/* ENUM -> STRINGA --------------------------------------------------------------- */
void show_error(int error){
    switch(error){
        case MISSING_BYTES:
            printf("\nframmentazione non prevista del messaggio\n");
            break;
        case DISCONNECTION:
            // recv == 0
            printf("\nimpossibile ricevere messaggi per disconnessione della controparte\n");
            break;
        case ABRUPT_DISCONNECTION_R:
            // ECONNRESET
            printf("\nimpossibile ricervere messaggi per disconnessione brusca della controparte\n");
            break;
        case ABRUPT_DISCONNECTION_W:
            // ECONNRESET
            printf("\nimpossibile mandare messaggi per disconnessione brusca della controparte\n");
            break;
        case BROKEN_PIPE:
            // EPIPE
            printf("\nimpossibile mandare messaggi per disconnessione della controparte \n");
            break;
        case GENERIC_ERROR:
            printf("\nerrore di comunicazione\n");
            break;
        case NOT_ENOUGH_SPACE:
            printf("\nla malloc del buffer non è andata a buon fine\n");
            break;
        default:
            printf("\nunreachable\n");
            // include bug e problemi di ritorno non analizzati (unreachable)
    }
}




