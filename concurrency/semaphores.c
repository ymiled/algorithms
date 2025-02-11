#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<pthread.h>
#include<semaphore.h>
#include<assert.h>


#define TAILLE_MAX = 10

struct file {
    int *contenu;
    int nb_elem;
    int deb;
    int fin;
};
typedef struct file file;

struct buffer {
    file *data;
    sem_t *nb_free;
    sem_t *nb_used;
    pthread_mutex_t *lock;
};
typedef struct buffer buffer;

buffer *buf;

file* create_queue(){
    file *empty = malloc(sizeof(file));
    int *contenu = malloc(10 * sizeof(int));
    empty->contenu = contenu;
    empty->nb_elem = 0;
    empty->deb = 0;
    empty->fin = 0;
    return empty;
}

bool is_empty(file *f){
    return (f->nb_elem == 0);
}

bool is_full(file *f){
    return (f->nb_elem == 10);
}

void push(file *f, int x){
    assert(!(is_full(f)));
    f->contenu[f->fin] = x;
    f->fin = (f->fin + 1) % 10;
    f->nb_elem ++;
}

int pop(file *f){
    assert(!(is_empty(f)));
    int x = f->contenu[f->deb];
    f->deb = (f->deb + 1) % 10;
    f->nb_elem --;
    return x;
}

void free_queue(file *f){
    free(f->contenu);
    free(f);
}

buffer *create_buf(){
    buffer *buf = malloc(sizeof(buffer));
    file *q = create_queue();
    sem_t *nb_free = malloc(sizeof(sem_t));
    sem_t *nb_used = malloc(sizeof(sem_t));
    pthread_mutex_t *mutex = malloc(sizeof(pthread_mutex_t));
    sem_init(nb_free, 0, 10);
    sem_init(nb_used, 0, 0);
    pthread_mutex_init(mutex, NULL);
    buf->data = q;
    buf->nb_free = nb_free;
    buf->nb_used = nb_used;
    buf->lock = mutex;
    return buf;
}

void free_buffer(buffer *buf){
    free_queue(buf->data);
    sem_destroy(buf->nb_free);
    sem_destroy(buf->nb_used);
    pthread_mutex_destroy(buf->lock);
    free(buf);
}

void produce(buffer *buf, int item){
    sem_wait(buf->nb_free);
    pthread_mutex_lock(buf->lock);
    push(buf->data, item);
    pthread_mutex_unlock(buf->lock);
    sem_post(buf->nb_used);
}

int consume(buffer *buf){
    sem_wait(buf->nb_used);
    pthread_mutex_lock(buf->lock);
    int x = pop(buf->data);
    pthread_mutex_unlock(buf->lock);
    sem_post(buf->nb_free);
    return x;
}

void *f1(void* item){
    int x = * ((int *) item);
    produce(buf, x);
    printf("le thread %d produit...\n", x);
}

void *f2(void *num){
    int i = * ((int *) num);
    int x = consume(buf);
    printf("le thread %d a consommé %d\n", i, x);
}


int main(){
    buf = create_buf();
    int nb_producteur = 10;
    int nb_consommateur = 5;

    pthread_t prod[nb_producteur];
    pthread_t conso[nb_consommateur];
    int id_p[nb_producteur];
    int id_c[nb_consommateur];

    for(int i = 0; i < nb_producteur; i ++){
        id_p[i] = i;
    }
    
    for(int i = 0; i < nb_consommateur; i ++){
        id_c[i] = i;
    }

    for(int i = 0; i < nb_producteur; i ++){
        pthread_create(&prod[i], NULL, f1, &id_p[i]);
    }

    for(int i = 0; i < nb_consommateur; i ++){
        pthread_create(&conso[i], NULL, f2, &id_c[i]);
    }

    for(int i = 0; i < nb_producteur; i ++){
        pthread_join(prod[i], NULL);
    }

    for(int i = 0; i < nb_consommateur; i ++){
        pthread_join(conso[i], NULL);
    }
}
