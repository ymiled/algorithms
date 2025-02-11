#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdatomic.h>

#define n 10000
#define NB_THREADS 2

struct mutex {
    atomic_bool want[2];
    atomic_bool turn;
};

typedef struct mutex mutex;

mutex* verrou;

mutex* createlock(){
    mutex * m = (mutex *) malloc(sizeof(mutex));
    m->want[0] = false;
    m->want[1] = false;
    m->turn = 0;
    return m;
}

int unlock(mutex* m, int turn){
    m->want[turn] = false;
    return 0;
}

int lock(mutex* m, int turn){
    m->want[turn] = true;
    m->turn = 1 - turn;
    int other = 1 - turn;
    while(m->turn = other && m->want[other]){

    }
    return 0;
}

void destroy(mutex* m){
    free(m);
}

void* incr(void* arg){
    int* somme = ((int*) arg);
    for(int i = 0; i < n; i++){
        lock(verrou, verrou->turn);
        int tmp = *somme;
        *somme = tmp + 1;
        unlock(verrou, verrou->turn);
    }
    return NULL;

}


int main(void){
    verrou = createlock();
    int somme = 0;

    pthread_t t1;
    pthread_t t2;
    fprintf(stderr, "Début : somme = %d\n", somme);
    pthread_create(&t1, NULL, incr, &somme);
    pthread_create(&t2, NULL, incr, &somme);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    fprintf(stderr, "Fin : somme = %d\n", somme);

    destroy(verrou);
}



