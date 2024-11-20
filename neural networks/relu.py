import numpy as np


def relu(z, deriv=False):
    """ Calcule la valeur de la fonction relu ou de sa dérivée appliquée à z
    
    Parametres
    ----------
    z : peut être un scalaire ou une matrice
    deriv : booléen. Si False renvoie la valeur de la fonction relu, si True renvoie sa dérivée

    Return
    -------
    s : valeur de la fonction relu appliquée à z ou de sa dérivée. Même dimension que z

    """

    r = np.zeros(z.shape)
    if deriv:
        pos = np.where(z >= 0)
        r[pos] = 1.0
        return r
    else :    
        return np.maximum(r, z)

