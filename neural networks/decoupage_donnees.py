import numpy as np

def decoupage_donnees(x, d, prop_val=0.2, prop_test=0.2):
    """ Découpe les données initiales en trois sous-ensembles distincts d'apprentissage, de validation et de test
    
    Parametres
    ----------
    x : matrice des données de dimension [N, nb_var]
    d : matrice des valeurs cibles [N, nb_cible]
    prop_val : proportion des données de validation sur l'ensemble des données (entre 0 et 1)
    prop_test : proportion des données de test sur l'ensemble des données (entre 0 et 1)
    
    avec N : nombre d'éléments, nb_var : nombre de variables prédictives, nb_cible : nombre de variables cibles

    Retour
    -------
    x_app : matrice des données d'apprentissage
    d_app : matrice des valeurs cibles d'apprentissage
    x_val : matrice des données de validation
    d_val : matrice des valeurs cibles de validation
    x_test : matrice des données de test
    d_test : matrice des valeurs cibles de test 

    """

    N = x.shape[0]
    indices = np.arange(N)
    np.random.shuffle(indices)
    x_shuffled = x[indices]
    d_shuffled = d[indices]

    x_app = x_shuffled[0: int(N * (1 - prop_val - prop_test))]
    d_app = d_shuffled[0: int(N * (1 - prop_val - prop_test))]

    x_val = x_shuffled[int(N * (1 - prop_val - prop_test)): int(N * (1 - prop_test))]
    d_val = d_shuffled[int(N * (1 - prop_val - prop_test)): int(N * (1 - prop_test))]

    x_test = x_shuffled[int(N * (1 - prop_test)):]
    d_test = d_shuffled[int(N * (1 - prop_test)):]
    
    return x_app, d_app, x_val, d_val, x_test, d_test
    

