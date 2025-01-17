extern "C" void c_ceread(natl id, char* buf, natl quanti){
	if(id >= next_ce){
		flog(LOG_WARN,"ce non esistente");
		abort_p();
	}
	if(!access(reinterpret_cast<void*>(buf),quanti,true)){
		flog(LOG_WARN,"trojan on buf");
		abort_p();
	}
	des_ce* c = &array_ce[id];
	sem_wait(c->free_chan);
	sem_wait(c->mutex);
	 // c'è un canale libero
	natb i = 0;
	natb check = inputb(c->iCTL); // vediamo quale è
	for(;i < MAX_CHAN; ++i){
		if(!((1 << i) & check))
			break;
	}
	check |= (1 << i); // lo attivo
	des_chan* ch = &c->chan[i]; // ci setto le cose per il trasferimento
	ch->buf = buf;
	ch->quanti = quanti;
	outputb(check,c->iCTL); 
	sem_signal(c->mutex);// scrivo lo stato aggiornato dei canali in CTL
	sem_wait(ch->sync);  // aspetto il prossimo bit
	sem_signal(c->free_chan);
	
}

extern "C" void estern_ce(int id){
	des_ce* c = &array_ce[id];
	for(;;){

		natb i = inputb(c->iCHN);
		des_chan *ch = &c->chan[i];
		ch->quanti--;
		if(!ch->quanti){
			sem_wait(c->mutex); // devo poter accedere a iCTL della periferica
			natb check = inputb(c->iCTL);
			check &= ~(1 << i); 
			outputb(check,c->iCTL);
								 // disattivo il canale
					     	     // cosi non manderà più richieste di interruzione
			sem_signal(c->mutex); 
		}
		*ch->buf = inputb(c->iRBR);
		ch->buf++;
		if(!ch->quanti)
			sem_signal(ch->sync);
		wfi();
	}
}


