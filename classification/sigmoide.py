import numpy as np


def sigmoide(z):
    """ Calcule la valeur de la fonction sigmoide appliquée à z
    
    Parametres
    ----------
    z : peut être un scalaire ou une matrice

    Return
    -------
    s : valeur de sigmoide de z. Même dimension que z

    """

    s = 1 / (1 + np.exp(-z))
    return s
