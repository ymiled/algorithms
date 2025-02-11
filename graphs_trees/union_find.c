#include <stdio.h>
#include <stdlib.h>

struct partition {
    int num_elements;
    int* parent;
    int* rank;
    int* size;
};

typedef struct partition Partition;

Partition* create(int n){
    Partition* p = (Partition*) malloc(sizeof(Partition));
    p->num_elements = n;
    p->parent = (int*) malloc(n * sizeof(int));  // Allocate memory for all elements
    p->rank = (int*) malloc(n * sizeof(int));    // Allocate memory for all elements
    p->size = (int*) malloc(n * sizeof(int));    // Allocate memory for all elements
    for(int i = 0; i < n; i++){
        p->parent[i] = i;
        p->rank[i] = 0;
        p->size[i] = 1;
    }
    return p;
}

int find(Partition* p, int x){
    if (p->parent[x] != x){
        p->parent[x] = find(p, p->parent[x]);
    }
    return p->parent[x];
}

int union_sets(Partition* p, int x, int y){
    int root_x = find(p, x);
    int root_y = find(p, y);
    if (root_x == root_y){
        return root_x;
    }
    if (p->rank[root_x] < p->rank[root_y]){
        p->parent[root_x] = root_y;
        p->size[root_y] += p->size[root_x];   
        return root_y;     
    }
    p->parent[root_y] = root_x;
    p->size[root_y] += p->size[root_x];
    if (p->rank[root_x] == p->rank[root_y]){
        p->rank[root_x]++;
    } 
    return root_x;
}

int get_size(Partition* p, int x){
    return p->size[x];
}

void free_partition(Partition* p){
    free(p->parent);
    free(p->rank);
    free(p->size);
    free(p);
}

int main(){
    
}
