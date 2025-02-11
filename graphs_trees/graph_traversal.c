#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define MAXV 100

#define TREE 0
#define BACK 1
#define FORWARD 2
#define CROSS 3

struct edgenode {
  int y; // neighbor
  struct edgenode *next; // next in the list
};
typedef struct edgenode Edgenode;

struct graph {
  Edgenode *edges[MAXV]; // adjacency list array
  int degree[MAXV]; // degree of each vertex
  int nvertices;
  int nedges;
  bool directed; // indicates if the graph is directed
  bool discovered[MAXV]; // which vertices are known
  bool processed[MAXV]; // which vertices are processed
  int parent[MAXV]; // parent[x] is the parent of x in the traversal
                    // if there is none, it is -1

  int time;          // the clock
  int entry_time[MAXV];
  int exit_time[MAXV];
};
typedef struct graph Graph;

void initialize_graph(Graph *g, int n, bool directed) {
  g->nvertices = n;
  g->nedges = 0;
  g->directed = directed;
  for (int i = 0; i < MAXV; i++) {
    g->degree[i] = 0;
    g->edges[i] = NULL; 
  }
}

void insert_edge(Graph *g, int x, int y) {
  g->nedges++;
  g->degree[x]++;

  Edgenode *to_y = (Edgenode *) malloc(sizeof(Edgenode));
  to_y->y = y;
  to_y->next = g->edges[x];
  g->edges[x] = to_y;

  if (!g->directed) {
    g->degree[y]++;
    Edgenode *to_x = (Edgenode *) malloc(sizeof(Edgenode));
    to_x->y = x;
    to_x->next = g->edges[y];
    g->edges[y] = to_x;
  }
}

void read_graph(Graph *g) {
  int n, m, d;
  scanf("%d %d %d", &n, &m, &d);
  initialize_graph(g, n, d);
  g->directed = (d == 1);
  for (int i = 0; i < m; i++) {
    int x, y;
    scanf("%d %d", &x, &y);
    insert_edge(g, x, y);
  }
}

void free_edges(Graph *g) {
  Edgenode *list;
  for (int i = 0; i < MAXV; i++) {
    while (g->edges[i] != NULL) {
      list = g->edges[i];
      g->edges[i] = g->edges[i]->next;
      free(list);
    }
  }
}

void initialize_search(Graph *g) {
  for (int i = 0; i < MAXV; i++) {
    g->discovered[i] = false;
    g->processed[i] = false;
    g->parent[i] = -1;
  }
}

void process_vertex_early(Graph *g, int v) {
  printf("[start] processing vertex %d\n", v);
}

void process_vertex_late(Graph *g, int v) {
  printf("[done] processing vertex %d\n", v);
}

void process_edge(Graph *g, int x, int y) {
  printf("* processing edge %d --> %d\n", x, y);
}

void explore(Graph *g, int x, int v) {
  if (!g->discovered[v]) {
    g->discovered[v] = true;
    for (Edgenode *e = g->edges[v]; e != NULL; e = e->next) {
      process_edge(g, x, e->y);
      explore(g, x, e->y);
    }
  }
}

void dfs(Graph *g, int x) {
  g->discovered[x] = true;
  process_vertex_early(g, x);
  g->time++;
  g->entry_time[x] = g->time;
  printf("* entry_time = %d\n", g->entry_time[x]);
  explore(g, x, x);
  process_vertex_late(g, x);
  g->time++;
  g->exit_time[x] = g->time;
  printf("* exit_time = %d\n", g->exit_time[x]);
}

void all_dfs(Graph *g) {
  for (int i = 0; i < g->nvertices; i++) {
    if (!g->discovered[i]) {
      dfs(g, i);
    }
  }
}


int main(void) {
  Graph g;
  read_graph(&g);
  int n = g.nvertices;
  int a = g.nedges;
  printf("graph size = %d\nnumber of edges = %d\n", n, a);
  free_edges(&g);
}
