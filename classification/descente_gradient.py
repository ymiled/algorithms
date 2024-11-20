import numpy as np
from calcule_cout import *
from sigmoide import *

def descente_gradient(X, Y, theta, alpha, nb_iters):
    """ Apprentissage des parametres de regression linéaire par descente du gradient
    
    Parametres
    ----------
    X : matrice des données de dimension [N, nb_var+1]
    Y : matrice contenant les valeurs de la variable cible de dimension [N, 1]
    theta : matrices contenant les paramètres theta du modèle linéaire de dimension [1, nb_var+1]
    alpha : taux d'apprentissage
    nb_iters : nombre d'itérations
    
    avec N : nombre d'éléments et nb_var : nombre de variables prédictives


    Retour
    -------
    theta : matrices contenant les paramètres theta appris par descente du gradient de dimension [1, nb_var+1]
    J_history : tableau contenant les valeurs de la fonction cout pour chaque iteration de dimension nb_iters


    """
    
    # Initialisation de variables utiles
    N = X.shape[0]
    J_history = np.zeros(nb_iters)

    for i in range(0, nb_iters):
        f = sigmoide(np.dot(X, theta.T))
        dj_dtheta = (1/N) * np.dot((f - Y).T, X)
        theta = theta - alpha * dj_dtheta
        J_history[i] = calcule_cout(X, Y, theta)            

    return theta, J_history

