import numpy as np


def sigmoide(z, deriv=False):
    """ Calcule la valeur de la fonction sigmoide ou de sa dérivée appliquée à z
    
    Parametres
    ----------
    z : peut être un scalaire ou une matrice
    deriv : booléen. Si False renvoie la valeur de la fonction sigmoide, si True renvoie sa dérivée

    Return
    -------
    s : valeur de la fonction sigmoide appliquée à z ou de sa dérivée. Même dimension que z

    """

    s = 1 / (1 + np.exp(-z))
    if deriv:
        return s * (1 - s)
    else :
        return s

