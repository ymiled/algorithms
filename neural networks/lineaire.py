import numpy as np


def lineaire(z, deriv=False):
    """ Calcule la valeur de la fonction linéaire ou de sa dérivée appliquée à z
    
    Parametres
    ----------
    z : peut être un scalaire ou une matrice
    deriv : booléen. Si False renvoie la valeur de la fonction linéire, si True renvoie sa dérivée


    Return
    -------
    s : valeur de la fonction linéaire appliquée à z ou de sa dérivée. Même dimension que z

    """
    if deriv:       
        return 1     
    else :
        return z
