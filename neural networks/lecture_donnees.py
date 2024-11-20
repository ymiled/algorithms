import numpy as np

def lecture_donnees(nom_fichier, type, delimiteur=','):
    """ Lit le fichier contenant les données et renvoie les matrices correspondant

    Parametres
    ----------
    nom_fichier : nom du fichier contenant les données
    delimiteur : caratère délimitant les colonne dans le fichier ("," par défaut)

    Retour
    -------
    x : matrice des données de dimension [N, nb_var]
    d : matrice contenant les valeurs de la variable cible de dimension [N, nb_cible]
    N : nombre d'éléments
    nb_var : nombre de variables prédictives
    nb_cible : nombre de variables cibles

    """
    
    # Lecture des données
    data = np.loadtxt(nom_fichier, delimiter=delimiteur, dtype=object)
    nb_var = data.shape[1] - 1

    if type == "regression":
        nb_cible = 1
    else:
        nb_cible = np.unique(data[:, nb_var]).shape[0] 
    N = data.shape[0]
    X = data[:, 0:nb_var].astype(float)
    Y = data[:, nb_var].reshape(N, 1)

    unique_values = np.unique(Y)
    mapping = {unique_values[i]: i for i in range(len(unique_values))}
    Y = np.array([mapping[Y[i, 0]] for i in range(N)]).reshape(N, 1)

    
    return X, Y, N, nb_var, nb_cible
    