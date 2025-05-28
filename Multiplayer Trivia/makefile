all: server client

server: server.c shared.c shared.h
	gcc -Wall server.c -o server

client: client.c shared.c shared.h
	gcc -Wall client.c -o client

run: server client
	gnome-terminal -- ./server &
	gnome-terminal -- ./client &