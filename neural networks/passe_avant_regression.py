import numpy as np

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

    h = [x]
    a = []
    for i in range(len(b)):
        a.append(W[i].dot(h[i]) + b[i])
        h.append(activation[i](a[-1]))

    return a, h