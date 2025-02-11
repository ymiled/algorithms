#include<stdio.h>
#include<stdbool.h>
#include<stdlib.h>

void swap(int tab[], int i, int j){
    int tmp = tab[i];
    tab[i] = tab[j];
    tab[j] = tmp;
}

void knuth_shuffle(int tab[], int n){
    for(int i = 0; i < n; i++){
        int j = rand() % (i + 1);
        swap(tab, i, j);
    }
}
void print_tab(int tab[], int n){
    printf("{");
    for(int i = 0; i < n - 1; i ++){
        printf("%d, ", tab[i]);
    }
    printf("%d}\n", tab[n - 1]);
}

int main(){
    int tab[9] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    print_tab(tab, 9);
    knuth_shuffle(tab, 9);
    print_tab(tab, 9);
    
}