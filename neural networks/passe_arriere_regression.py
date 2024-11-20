import numpy as np

def passe_arriere(delta_h, a, h, W, activation):
    """ Réalise une passe arrière dans le réseau de neurones (rétropropagation)
    
    Paramètres
    ----------
    delta_h : matrice contenant les valeurs du gradient du coût par rapport à la sortie du réseau
    a : liste contenant les potentiels d'entrée des couches du réseau
    h : liste contenant les sorties des couches du réseau
    W : liste contenant les matrices des poids du réseau
    activation : liste contenant les fonctions d'activation des couches du réseau

    Retourne
    -------
    delta_W : liste contenant les matrices des gradients des poids des couches du réseau
    delta_b : liste contenant les matrices des gradients des biais des couches du réseau
    """
    delta_b = []
    delta_W = []
    for i in range(len(W)-1, -1, -1):
        delta = delta_h * activation[i](a[i], True)
        delta_b.append(delta.mean())
        delta_W.append(delta.dot(np.transpose(h[i])))
        delta_h = np.transpose(W[i]).dot(delta)
        
    delta_b.reverse()
    delta_W.reverse()

    return delta_W, delta_b
