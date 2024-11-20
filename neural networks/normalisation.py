import numpy as np


def normalisation(x):
    """
    

    Parametres
    ----------
    x : matrice des données de dimension [N, nb_var]
    
    avec N : nombre d'éléments et nb_var : nombre de variables prédictives

    Retour
    -------
    x_norm : matrice des données centrées-réduites de dimension [N, nb_var]
    mu : moyenne des variables de dimension [1,nb_var]
    sigma : écart-type des variables de dimension [1,nb_var]

    """
    
    mu = np.mean(x, 0)
    sigma = np.std(x, 0)
    x_norm = (x - mu) / sigma

    return x_norm, mu, sigma
