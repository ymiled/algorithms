#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<string.h>
#include<assert.h>



struct TTT {
    int k;
    int n;
    int* grille;
};

typedef struct TTT ttt;

ttt* init_jeu(int n, int k){
    ttt *jeu = malloc(sizeof(ttt));
    int *grille = malloc(n * n * sizeof(int));
    jeu->k = k;
    jeu->n = n;
    jeu->grille = grille;
    return jeu;
}

void libere_jeu(ttt* jeu){
    free(jeu->grille);
    free(jeu);
}

int* repartition(ttt* jeu){
    int* repart = malloc(3 * sizeof(int));
    for(int i = 0; i < 3; i ++){
        repart[i] = 0;
    }
    for(int i = 0; i < jeu->n * jeu->n; i++){
        int val = jeu->grille[i];
        assert(0 <= val && val < 3);
        repart[val] ++;
    }
    return repart;
}

int joueur_courant(ttt* jeu){
    // le joueur dont c'est le tour est celui qui a le moins joué, 1 fois de moins
    int* repart = repartition(jeu);
    if(repart[0] == 0){
        return 0;
    }
    else{       
        if (repart[1] == repart[2]){
            return 1;
        }
        else{
            return 2;
        }
    }
}

void jouer_coup(ttt* jeu, int lgn, int cln){
    if(jeu->grille[lgn * jeu->n + cln] != 0){
        printf("coup impossible");
    }
    else{
        jeu->grille[lgn * jeu->n + cln] = (joueur_courant(jeu));
    }
}

bool alignement(ttt* jeu, int i, int di, int joueur){
    int n = jeu->n;
    int k = jeu->k;
    // on garde en mémoire la colonne et la ligne où on est :
    int cln = i % n; 
    int lgn = i / n;
    // on définit le déplacement suivant les colonnes et les lignes :
    int dc = ((di + 1) % n) - 1; // si on est tout à droite dc =  - 1
    int dl = (di + 1) / n;
    for(int j = 0; j < k; j++){
        //on vérifie qu'on ne sort pas de la grille
        if(cln < 0 || cln >= n || lgn < 0 || lgn >= n){
            return false;
        }
        int pos = lgn * n + cln;
        if(jeu->grille[pos] != joueur){
            return false;
        }
        cln += dc;
        lgn += dl;
    }
    return true;
}

bool gagnant(ttt* jeu, int joueur){
    int n = jeu->n;
    int tabdi[4] = {1, n - 1, n, n + 1}; // les déplacements possibles
    for(int i = 0; i < n * n; i ++){
        for(int j = 0; j < n; j ++){
            if(alignement(jeu, i, tabdi[j], joueur)){
                return true;
            }
        }
    }
    return false;
}

int puiss(int x, int k){
    // calcule a^k
    int y = 1;
    while(k > 0){
        if(k % 2 == 1){
            y = y * x;
        }
        else{
            x = x * x;
            k = k/2;
        }
    }
    return y;
}

int encodage(ttt* jeu){
    int res = 0;
    for(int i = 0; i < jeu->n * jeu->n; i ++){
        res = 3 * res + jeu->grille[i];
    }
    return res;
}

int main(){

}