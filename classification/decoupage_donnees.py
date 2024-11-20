import numpy as np 

def decoupage(x, y, prop_app=0.8):
    """
    Découpe les données en un ensemble d'apprentissage et un ensemble de test.
    Parametres
    ----------
    x : matrice des données de dimension [N, nb_var]
    y : matrice des valeurs cibles [N, nb_cible]
    prop_app : proportion des données d'apprentissage sur l'ensemble des données (entre 0 et 1)

    avec N : nombre d'éléments, nb_var : nombre de variables prédictives, nb_cible : nombre de variables cibles

    Retour
    -------
    x_app : matrice des données d'apprentissage
    y_app : matrice des valeurs cibles d'apprentissage
    x_test : matrice des données de test
    y_test : matrice des valeurs cibles de test 

    """

    N = x.shape[0]
    indices = np.arange(N)
    np.random.shuffle(indices)
    x_shuffled = x[indices]
    y_shuffled = y[indices]
    x_app = x_shuffled[0: int(N * prop_app)]
    y_app = y_shuffled[0: int(N * prop_app)]

    x_test = x_shuffled[int(N * prop_app):]
    y_test = y_shuffled[int(N * prop_app):]


    return x_app, y_app, x_test, y_test
   