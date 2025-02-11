#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

struct tas {
  int* contenu;
  int taille;
  int capacite;
};

typedef struct tas tas;

tas* creer_tas_vide(int capacite) {
  if (capacite <= 0) {capacite = 1;}
  tas* t = malloc(sizeof(tas));
  t->contenu = malloc(capacite * sizeof(int));
  t->taille = 0;
  t->capacite = capacite;
  for (int i = 0; i < capacite; i++) {
    t->contenu[i] = 42;
  }
  return t;
}

void detruire_tas(tas* t) {
  free(t->contenu);
  free(t);
}

bool est_vide(tas* t) {
  return t->taille == 0;
}

inline int fg(int i) {return 2 * i + 1;}

inline int fd(int i) {return 2 * i + 2;}

inline int pere(int i) {return (i - 1) / 2;}

void echange(int i, int j, tas* t) {
  int tmp = t->contenu[i];
  t->contenu[i] = t->contenu[j];
  t->contenu[j] = tmp;
}

void percoler_haut(int i, tas* t) {
  while (i > 0 && t->contenu[i] < t->contenu[pere(i)]) {
    echange(i, pere(i), t);
    i = pere(i);
  }
}

int argmin3(int i, int j, int k, tas* t) {
  if (j < t->taille && t->contenu[j] < t->contenu[i]) {
    i = j;
  }
  if (k < t->taille && t->contenu[k] < t->contenu[i]) {
    i = k;
  }
  return i;
}

void percoler_bas(int i, tas* t) {
  int j = argmin3(i, fg(i), fd(i), t);
  while (i != j) {
    echange(i, j, t);
    i = j;
    j = argmin3(i, fg(i), fd(i), t);
  }
}

void inserer(int element, tas* t) {
  if (t->taille == t->capacite) {
    t->capacite *= 2;
    // t->contenu = realloc(t->contenu, t->capacite * sizeof(int));
    int* nouveau_contenu = malloc(t->capacite * sizeof(int));
    for (int i = 0; i < t->taille; i++) {
      nouveau_contenu[i] = t->contenu[i];
    }
    free(t->contenu);
    t->contenu = nouveau_contenu;
  }
  t->contenu[t->taille] = element;
  percoler_haut(t->taille, t);
  t->taille++;
}

int minimum(tas* t) {
  assert(t->taille > 0);
  return t->contenu[0];
}

int extraire_min(tas* t) {
  assert(t->taille > 0);
  int res = t->contenu[0];
  t->taille--;
  t->contenu[0] = t->contenu[t->taille];
  percoler_bas(0, t);
  return res;
}

int main(void) {

}
