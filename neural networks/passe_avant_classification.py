import numpy as np
from softmax import softmax

def passe_avant(x, W, b, activation):
    """ Réalise une passe avant dans le réseau de neurones
    
    Parametres
    ----------
    x : matrice des entrées, de dimension nb_var x N
    W : liste contenant les matrices des poids du réseau
    b : liste contenant les matrices des biais du réseau
    activation : liste contenant les fonctions d'activation des couches du réseau

    avec N : nombre d'éléments, nb_var : nombre de variables prédictives 

    Return
    -------
    a : liste contenant les potentiels d'entrée des couches du réseau
    h : liste contenant les sorties des couches du réseau

    """

    a = []
    h = [x]  # Start with input as the first 'output' layer
    for i in range(len(W)):
        product = W[i].dot(h[i].T).T
        b_expanded = np.zeros(product.shape)
        for j in range(product.shape[0]):
            b_expanded[j] = b[i].reshape(-1)

        z = product + b_expanded
        
        a.append(z)
        h.append(activation[i](z))  # Use specified activation for hidden layers
    return a, h
