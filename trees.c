#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>

struct node {
  int key;
  struct node* left;
  struct node* right;
  struct node* parent;
};

typedef struct node node;

node* leaf(int key) {
  node* f = malloc(sizeof(node));
  f->key = key;
  f->left = NULL;
  f->right = NULL;
  f->parent = NULL;
  return f;
}

bool is_leaf(node* n) {
  return (n != NULL && n->left == NULL && n->right == NULL);
}

// Question 3
node* root(int key, node* left, node* right) {
  assert(left == NULL || (left->parent == NULL && left != right));
  assert(right == NULL || right->parent == NULL);
  node* n = malloc(sizeof(node));
  n->key = key;
  n->left = left;
  n->right = right;
  n->parent = NULL;
  if (left != NULL) { left->parent = n; }
  if (right != NULL) { right->parent = n; }
  return n;
}


node* parent(node* n) {
  if (n == NULL) {
    return NULL;
  } else {
    return n->parent;
  }
}

node* grandparent(node* n) {
  return parent(parent(n));
}

node* sibling(node* n) {
  node* p = parent(n);
  if (p == NULL) {
    return NULL;
  } else if (p->left == n) {
    return p->right;
  } else {
    return p->left;
  }
}

node* uncle(node* n) {
  return sibling(parent(n));
}

int size_rec(node* n) {
  if (n == NULL) {
    return 0;
  } else {
    return 1 + size_rec(n->left) + size_rec(n->right);
  }
}

int depth_it(node* n) {
  assert(n != NULL);
  int p = 0;
  while (n->parent != NULL) {
    n = n->parent;
    p++;
  }
  return p;
}

void free_tree_rec(node* n) {
  if (n != NULL) {
    free_tree_rec(n->left);
    free_tree_rec(n->right);
    free(n);
  }
}


void print_infix_rec(node* n) {
  if (n != NULL) {
    print_infix_rec(n->left);
    printf("%d\n", n->key);
    print_infix_rec(n->right);
  }
}

node* search_rec(int key, node* bst) {
  if (bst == NULL || bst->key == key) {
    return bst;
  } else if (key < bst->key) {
    return search_rec(key, bst->left);
  } else {
    return search_rec(key, bst->right);
  }
}

node* search_it(int key, node* bst) {
  while (bst != NULL && bst->key != key) {
    if (key < bst->key) {
      bst = bst->left;
    } else {
      bst = bst->right;
    }
  }
  return bst;
}

node* minimum_it(node* bst) {
  if (bst == NULL) { return NULL; }
  while (bst->left != NULL) {
    bst = bst->left;
  }
  return bst;
}

node* maximum_rec(node* bst) {
  if (bst == NULL || bst->right == NULL) {
    return bst;
  }
  return maximum_rec(bst->right);
}

node* insert_it(int key, node* bst) {
  node* parent = NULL;
  node* child = bst;
  while (child != NULL) {
    parent = child;
    if (key <= child->key) {
      child = child->left;
    } else {
      child = child->right;
    }
  }
  if (parent == NULL) {
    return leaf(key);
  } else if (key <= parent->key) {
    parent->left = leaf(key);
    parent->left->parent = parent;
  } else {
    parent->right = leaf(key);
    parent->right->parent = parent;
  }
  return bst;
}

node* insert_rec(int key, node* bst) {
  if (bst == NULL) {
    bst = leaf(key);
  } else if (key <= bst->key) {
    bst->left = insert_rec(key, bst->left);
    if (bst->left != NULL) { bst->left->parent = bst; }
  } else {
    bst->right = insert_rec(key, bst->right);
    if (bst->right != NULL) { bst->right->parent = bst; }
  }
  return bst;
}

node* delete_it(int key, node* bst) {
  node* z = search_it(key, bst);
  if (z == NULL) { return bst; }
  // node to be deleted, actually called y
  node* y = z;
  if (z->left != NULL && z->right != NULL) {
    y = minimum_it(z->right);
    // Replace z with y
    z->key = y->key;
  }
  // y will be deleted and has only one child, called x
  node* x = y->left;
  if (y->right != NULL) {
    assert(y->left == NULL);
    x = y->right;
  }
  // Detach y
  if (y->parent == NULL) {
    // Special case: y was the root of the tree
    bst = x;
    x->parent = NULL;
  } else if (y->parent->left == y) {
    // y is a left child
    y->parent->left = x;
    x->parent = y->parent;
  } else {
    // y is a right child
    assert(y->parent->right == y);
    y->parent->right = x;
    x->parent = y->parent;
  }
  // Don't forget to free y
  free(y);
  return bst;
}

// Question 22
/* Fills the array starting from position `i` with keys from the
   subtree rooted at `n` in ascending order and returns the position
   just after the last inserted element. */
int fill_array(int* array, int i, node* n) {
  if (n == NULL) { return i; }
  int j = fill_array(array, i, n->left);
  array[j] = n->key;
  return fill_array(array, j + 1, n->right);
}

void sort(int size, int* array) {
  node* n = NULL;
  for (int i = 0; i < size; i++) {
    n = insert_it(array[i], n);
  }
  int end = fill_array(array, 0, n);
  assert(end == size);

  free_tree_rec(n);
}



node* successor(node* n) {
  assert(n != NULL);
  if (n->right != NULL) {
    return minimum_it(n->right);
  }
  node* p = n->parent;
  while (p != NULL && p->right == n) {
    n = p;
    p = p->parent;
  }
  return p;
}

// Question 25
void print_infix_it(node* n) {
  n = minimum_it(n);
  while (n != NULL) {
    printf("%d\n", n->key);
    n = successor(n);
  }
}

/* Recursive function. Fills the array starting from position `i`
   with keys from the subtree rooted at `n` in ascending order and
   returns the position just after the last inserted element. */
int fill_array_rec(int* array, int i, node* n) {
  if (n == NULL) { return i; }
  int j = fill_array_rec(array, i, n->left);
  array[j] = n->key;
  return fill_array_rec(array, j + 1, n->right);
}


void insertion_sort(int size, int* array) {
  int i = 1;
  while (i < size) {
    int key = array[i];
    int j = i - 1;
    while (j >= 0 && array[j] > key) {
      array[j + 1] = array[j];
      j--;
    }
    array[j + 1] = key;
    i++;
  }
}

void free_tree_it(node* n) {
  node* tmp;
  while (n != NULL) {
    if (n->left != NULL) {
      n = n->left;
    } else if (n->right != NULL) {
      n = n->right;
    } else {
      tmp = n->parent;
      free(n);
      if (tmp == NULL) {
        n = NULL;
      } else if (tmp->left == n) {
        tmp->left = NULL;
        n = tmp;
      } else if (tmp->right == n) {
        tmp->right = NULL;
        n = tmp;
      }
    }
  }
}