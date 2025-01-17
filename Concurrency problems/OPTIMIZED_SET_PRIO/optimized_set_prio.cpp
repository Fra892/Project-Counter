
bool rimozione_lista_sel(des_proc*& testa, natl id){
	des_proc **p = &testa;
	while(*p && (*p)->id !=id)
		p = &(*p)->puntatore;
	if(!*p)
		return false;
	*p = (*p)->puntatore; // non dobbiamo fare il delete 
			              // sennò non possiamo reinserirlo;
	return true;
}



extern "C" void c_set_prio(natl id , natl prio){

	if(id >= MAX_PROC_ID){
		flog(LOG_WARN,"id non valido");
		c_abort_p();
		return;
	}

	if(prio > esecuzione->precedenza){
		flog(LOG_WARN,"priorità maggiore");
		c_abort_p();
		return;
	}

	des_proc *p = des_p(id);

	if(!p){
		esecuzione->contesto[I_RAX] = false;
		return;
	}

	if(p->livello == LIV_SISTEMA){
		flog(LOG_WARN,"processo di livello sistema");
		c_abort_p();
		return;
	}



	esecuzione->contesto[I_RAX] = true;
	p->precedenza = prio; // setto la precedenza

	for(natl i = 0; i < MAX_SEM + sem_allocati_sistema; i++){
		des_sem *s = &array_dess[i];
		if(rimozione_lista_sel(s->pointer,p->id)){
			inserimento_lista(s->pointer,p);
			return;
		}
		if(i == sem_allocati_utente)
			i = MAX_SEM;
	}

	if(rimozione_lista_sel(pronti,p->id)){
		inspronti();
		inserimento_lista(pronti,p);
		schedulatore();
		return;
	}
	/* la coda del timer non dipende dalla priorità 
	    bensì dal  parametro passato alla c_delay
	    ergo non dobbiamo fare niente 
	*/

	/* inoltre se è il processo in esecuzione
	   vuol dire che ha la priorità maggiore
	   se ne modifichiamo la priorità dobbiamo
	   portare in coda pronti il nostro nuovo processe
	   e fare schedulatore per far si che sia
	   in esecuzione il processo con 
	   priorità più alta 
	*/
	
	inserimento_lista(pronti,esecuzione);
	schedulatore();

}
