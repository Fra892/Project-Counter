extern "C" void c_rw_upgrade(natl rw){
    if(!rw_valido(rw)){
        flog(LOG_WARN,"rw_upgrade(%d): rwlock non valido",rw);
        c_abort_p();
        return;
    }
    des_rw *r = &array_desrw[rw];
    des_proc_rw *rp;
    /* test non ha lock */
    if(!rw_proc_find(r)){
        flog(LOG_WARN,"rw_upgrade(%d): il processo non possiede un lock ",rw);
        c_abort_p();
        return;
    }
    rp= rw_proc_find(r);
    /* test deve avere un lock in lettura */
    if(rp->state == RW_WRITER || rp->state == RW_NONE){
        flog(LOG_WARN,"rw_upgrade(%d): il processo non possiede un lock in lettura",rw);
        c_abort_p();
        return;
    }
    rp->state = RW_UPGRADED; // devo differenziarlo da i processi che chiamano c_writelock
    r->nreaders--;
    if(!r->nreaders){
        inserimento_lista(r->w_writers,esecuzione);
        des_proc * work = rimozione_lista(r->w_writers);
        des_proc_rw *work_lock = rw_proc_find(r,work);
        work_lock->state = (work_lock->state == RW_NONE)? RW_WRITER : RW_UPGRADED;
        if(work_lock->state == RW_WRITER)
            work->contesto[I_RAX] = true;
        // se ha come stato NONE vuol dire
        // che veniva da una write e non fa una
        // upgrade dunque dobbiamo restuituirgli il
        // ritorno della rw_wirtelock = true
        r->writer = work->id;
        inserimento_lista(pronti,work);
        schedulatore();
    } else {
        inserimento_lista(r->w_writers, esecuzione);
        schedulatore();
    }
    // alla fine di questa primitiva un processo con un lock di tipo upgraded
    // potrebbe essere in lista wait per i waiters
}


extern "C" void c_rw_downgrade(natl rw){
    if(!rw_valido(rw)){
        flog(LOG_WARN,"rw_downgrade(%d): rwlock non valido", rw);
        c_abort_p();
        return;
    }
    des_rw *r = &array_desrw[rw];
    des_proc_rw *rp;
    if(!rw_proc_find(r)){
        flog(LOG_WARN,"rw_downgrade(%d): il processo non possiede un lock",rw);
        c_abort_p();
        return;
    }
    rp= rw_proc_find(r);
    if(rp->state == RW_NONE){
        flog(LOG_WARN, "rw_downgrade(%d): non si possiede nessun tipo di lock",rw);
        c_abort_p();
        return;
    }
    // il processo ha il lock in scrittura UPGRADED
    if(rp->state == RW_UPGRADED){
        // anche se il processo con RW_UPGRADED potrebbe essere in lista wait per i waiters
        // se ha chiamato questa primitiva deve essere tornato in esecuzione
        // e dunque deve essere stato rimosso dalla lista di attesa
        // dunque ha per forza il lock in scrittura upgraded
        inserimento_lista(r->w_readers,esecuzione);
        r->writer = 0;
        // si da la precedenza ai processi lettori
        while(r->w_readers){
            des_proc* work = rimozione_lista(r->w_readers);
            des_proc_rw* work_lock = rw_proc_find(r,work);
            if(work_lock->state ==RW_NONE)
                work->contesto[I_RAX] = true;
            work_lock->state = RW_READER;
            inserimento_lista(pronti,work);
            r->nreaders++;

        }
        schedulatore();
    } else if( rp->state == RW_WRITER ){
        inspronti();
        rp->r = nullptr; // togliamo il lock
        r->writer = 0;
        if(!r->w_readers && r->w_writers){
            des_proc* work = rimozione_lista(r->w_writers);
            des_proc_rw* work_lock = rw_proc_find(r,work);
            work_lock->state = (work_lock->state == RW_NONE)? RW_WRITER : RW_UPGRADED;
            if(work_lock->state == RW_WRITER)
                work->contesto[I_RAX] = true;
            r->writer = work->id;
            inserimento_lista(pronti,work);
            schedulatore();
            return;
        }
        while(r->w_readers){
            des_proc* work = rimozione_lista(r->w_readers);
            inserimento_lista(pronti,work);
            des_proc_rw* work_lock = rw_proc_find(r,work);
            if(work_lock->state == RW_NONE)
                work->contesto[I_RAX] = true;
            work_lock->state = RW_READER;
            r->nreaders++;
        }
        schedulatore();
    } else if(rp->state == RW_READER){
        inspronti();
        rp->r = nullptr; //togliamo il lock
        r->nreaders--;
        if(!r->nreaders && r->w_writers){
            des_proc* work = rimozione_lista(r->w_writers);
            des_proc_rw* work_lock = rw_proc_find(r,work);
            work_lock->state = (work_lock->state == RW_NONE)? RW_WRITER : RW_UPGRADED;
            if(work_lock->state == RW_WRITER)
                work->contesto[I_RAX] = true;
            r->writer = work->id;
            inserimento_lista(pronti,work);
        }
        schedulatore();
    }
}
