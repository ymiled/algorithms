#include <stdatomic.h>
#include <stdbool.h>
#include <stdlib.h>

#define NB_THREADS 4

struct mutex {
    atomic_bool want[NB_THREADS];
    atomic_int ticket[NB_THREADS];
};


typedef struct mutex mutex;

mutex* create(){
    mutex* m = malloc(sizeof(mutex));
    atomic_bool want[NB_THREADS] = {false};
    atomic_int ticket[NB_THREADS] = {0};
    for(int i = 0; i < NB_THREADS; i++){
        m->want[i] = want[i];
        m->ticket[i] = ticket[i];

    }
    return m;
}


void unlock(mutex* m, int i){
    m->want[i] = false;
}
int maxi(atomic_int* tab){
    int res = 0;
    for(int i = 0; i < NB_THREADS; i++){
        if(res < tab[i]){
            res = tab[i];
        }    
    }
    return res;
}

bool lexico(int a1, int b1, int a2, int b2){ //ordre lexicographique
    return ((a1 < a2) || (a1 == a2 && b1 < b2));
}

bool existe_j_cond(mutex* m, int i){
    for(int j = 0; j < NB_THREADS; j++){
        if(m->want[j] && lexico(m->ticket[j], j, m->ticket[i], i)){
            return true;
        }
    }
    return false;
}

void lock(mutex* m, int i){
    m->want[i] = true;
    m->ticket[i] = (maxi(m->ticket)) + 1;
    while(existe_j_cond(m, i)){

    }

}

int main(){
    mutex* m = create();
    lock(m, 1);


}