import numpy as np


def normalisation(X):
    """
    

    Parametres
    ----------
    X : matrice des données de dimension [N, nb_var]
    
    avec N : nombre d'éléments et nb_var : nombre de variables prédictives

    Retour
    -------
    X_norm : matrice des données centrées-réduites de dimension [N, nb_var]
    mu : moyenne des variables de dimension [1,nb_var]
    sigma : écart-type des variables de dimension [1,nb_var]

    """

    # tableau de dimension [1,nb_var] contenant des zéros
    mu = np.zeros((1, X.shape[1]))
    sigma = np.zeros((1, X.shape[1]))

    X_norm = np.zeros(X.shape)

    for i in range(X.shape[1]):
        mu[0, i] = np.mean(X[:, i])
        sigma[0, i] = np.std(X[:, i])

        if sigma[0, i] != 0:
            # centrage-réduction :
            X_norm[:, i] = (X[:, i] - mu[0, i]) / sigma[0, i]


    return X_norm, mu, sigma