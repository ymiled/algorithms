#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>

typedef struct node node;
struct node {
  bool black;
  int key;
  node* left;
  node* right;
  node* parent;
};

/** Utility Functions **/

// A new leaf is colored red
node* create_leaf(int key) {
  node* f = malloc(sizeof(node));
  f->black = false;
  f->key = key;
  f->left = NULL;
  f->right = NULL;
  f->parent = NULL;
  return f;
}

// Useful for creating examples
node* create_black_leaf(int key) {
  node* f = create_leaf(key);
  f->black = true;
  return f;
}

node* create_root(int key, node* left, node* right, bool black) {
  assert(left == NULL || left->parent == NULL && left != right);
  assert(right == NULL || right->parent == NULL);
  node* n = malloc(sizeof(node));
  n->key = key;
  n->left = left;
  n->right = right;
  n->parent = NULL;
  n->black = black;
  if (left != NULL) {left->parent = n;}
  if (right != NULL) {right->parent = n;}
  return n;
}

void print_inorder_aux(node* n) {
  if (n != NULL) {
    print_inorder_aux(n->left);
    printf("%d-%c ", n->key, n->black ? 'B' : 'R');
    print_inorder_aux(n->right);
  }
}

// Inorder traversal of nodes with their color. Useful for some tests
void print_inorder(node* tree) {
  print_inorder_aux(tree);
  printf("\n");
}

node* root(node* n) {
  assert (n != NULL);
  while (n->parent != NULL) {
    n = n->parent;
  }
  return n;
}

int height(node* n) {
  if (n ==  NULL) {
    return 0;
  } else {
    int left_height = height(n->left);
    int right_height = height(n->right);
    return 1 + (left_height < right_height ? right_height : left_height);
  }
}

int black_height(node* n) {
  int h = 0;
  while (n != NULL) {
    n = n->left;
    if (n->black) {h++;}
  }
  return h;
}

// To be called only on the root of a tree
void free_tree(node* n) {
  if (n != NULL) {
    free_tree(n->left);
    free_tree(n->right);
    free(n);
  }
}

/** Some Genealogy **/

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

/** Rotations **/

// Note: These rotations may change the root of the tree. This is
// not a problem, we will be able to find it.

void rotate_left(node* x) {
  assert (x != NULL && x->right != NULL);
  node* y = x->right;
  // The left child of y becomes the right child of x
  x->right = y->left;
  if (x->right != NULL) {x->right->parent = x;}
  // Raise node y by updating its parent
  y->parent = x->parent;
  if (y->parent != NULL) {
    if (y->parent->left == x) {
      y->parent->left = y;
    } else {
      assert(y->parent->right == x);
      y->parent->right = y;
    }
  }
  // The left child of y is now x
  y->left = x;
  x->parent = y;
}

void rotate_right(node* y) {
  assert (y != NULL && y->left != NULL);
  node* x = y->left;
  // The right child of x becomes the left child of y
  y->left = x->right;
  if (y->left != NULL) {y->left->parent = y;}
  // Raise node x by updating its parent
  x->parent = y->parent;
  if (x->parent != NULL) {
    if (x->parent->left == y) {
      x->parent->left = x;
    } else {
      assert (x->parent->right == y);
      x->parent->right = x;
    }
  }
  // The right child of x is now y
  x->right = y;
  y->parent = x;
}

/** Insertion **/

node* insert_without_fix(int key, node* tree) {
  node* parent_node = NULL;
  node* child = tree;
  while (child != NULL) {
    parent_node = child;
    if (key <= child->key) {
      child = child->left;
    } else {
      child = child->right;
    }
  }
  child = create_leaf(key);
  child->parent = parent_node;
  if (parent_node != NULL) {
    if (key <= parent_node->key) {
      parent_node->left = child;
    } else {
      parent_node->right = child;
    }
  }
  return child;
}

void fix_red(node* n) {
  assert (n != NULL && !n->black);
  node* p = n->parent;
  // As long as the parent is red, we have a red-red problem
  while (p != NULL && !p->black) {
    node* g = p->parent;
    // The grandparent exists and is black
    assert (g != NULL && g->black);
    if (p == g->left) {
      if (n == p->right) {
        rotate_left(p);
        n = p;
        p = n->parent;
      }
      rotate_right(g);
    } else {
      // Same thing by swapping left and right
      assert (p == g->right);
      if (n == p->left) {
        rotate_right(p);
        n = p;
        p = n->parent;
      }
      rotate_left(g);
    }
    // Recoloring after rotation
    n->black = true;
    // Start again with the red root of the tree we just obtained
    assert (!p->black);
    n = p;
    p = n->parent;
  }
  // Finally color the root black if we are at it
  if (n->parent == NULL) {n->black = true;}
}

node* insert(int key, node* tree) {
  // Insert the key without fixing; we get a pointer to the leaf where the insertion took place
  node* n = insert_without_fix(key, tree);
  // This insertion may violate the red-black tree property.
  // We then fix it.
  fix_red(n);
  // The old root of the tree may have changed (moved down one level during a rotation); we return the correct root.
  if (tree == NULL) {
    tree = n;
  }
  return root(tree);
}

