import numpy as np


def taux_classification(Ypred,Y):
    """ Calcule le taux de classification (proportion d'éléments bien classés)
    
    Parametres
    ----------
    Ypred : matrice contenant les valeurs de classe prédites de dimension [N, 1]
    Y : matrice contenant les valeurs de la variable cible de dimension [N, 1]
    
    avec N : nombre d'éléments 


    Retour
    -------
    t : taux de classification (valeur scalaire)

    """

    t = np.mean(Ypred == Y)

    return t

