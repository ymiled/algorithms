#include<stdlib.h>
#include<stdbool.h>
#include<stdio.h>
#include<string.h>
#include<stdint.h>

#define B 256 
#define P 1869461003

int **build_table(char *m, int lm){
    int **table = malloc(lm * sizeof(int*));
    for(int j = 0; j < lm; j++){
        table[j] = malloc(256 * sizeof(int));
        for(int c = 0; c < 256; c++){
            table[j][c] = -1;
        }
        for(int k = 0; k < j; k++){
            unsigned char c = m[k];
            table[j][c] = k;
        }
    }
    return table;
}

void free_table(int **table, int lm){
    for(int j = 0; j < lm; j++){
        free(table[j]);
    }
    free(table);
}

int boyer_moore(char *m, char *t){
    int lm = strlen(m);
    int lt = strlen(t);
    int **table = build_table(m, lm);
    int count = 0;
    int i = 0;
    while (i <= lt - lm){
        int k = 0; // variable qui va servier à de combien on va avancer 
        for(int j = lm - 1; j >= 0; j--){
            if(t[i + j] != m[j]){
                unsigned char c = t[i + j];
                k = j - table[j][c]; // on avance de j - droite(x)
                break;
            }
        }
        if (k <= 0){
            printf("occurence à la position %d\n", i);
            count ++;
            k = 1; // on avance juste de 1
        }
        i += k;
    }
    free_table(table, lm);
    return count;
}


uint64_t math_power_mod(uint64_t x, uint64_t n, uint64_t p){
    uint64_t y = 1;
    while (n > 0){
        if (n % 2 == 1){
            y = (y * x) % p;
        }
        x = (x * x) % p; 
        n = n / 2;
    }
    return y;
}

uint64_t rk_hash(char *s, int len){
    uint64_t h = 0;
    for(int i = 0; i < len; i ++){
        unsigned char c = s[i];
        h = (B * h + c) % P;
    }
    return h;
}

int rabin_karp(char *m, char *t){
    int lm = strlen(m);
    int lt = strlen(t);
    assert(lm > 0);
    if(lt < lm){
        return 0;
    }
    uint64_t d = maths_power_mod(B, lm - 1, P);
    uint64_t target = rk_hash(m, lm);
    uint64_t h = rk_hash(t, lt);
    int count = 0;
    for(int i = 0; true; i ++){
        if (h == target && strncmp(&t[i], m, lm) == 0){
            printf("occurence à la position %d\n", i);
            count ++;
        }
        if (i == lt - lm){
            break;
        }
        unsigned char ci = t[i];
        h = (h + P - (d * ci) % P) % P; // on enlève t[i]
        unsigned char c = t[i + lm];
        h = (B * h + c) % P;            // et on rajoute t[i + lm]
    }
    return count;
}


int main(){

}