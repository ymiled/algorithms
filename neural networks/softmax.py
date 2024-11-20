import numpy as np

def softmax(z, deriv=False):
    """ Calcule la valeur de la fonction softmax ou de sa dérivée appliquée à z
    
    Parametres
    ----------
    z : peut être un scalaire, un vecteur ou une matrice
    deriv : booléen. Si False renvoie la valeur de la fonction softmax, si True renvoie sa dérivée

    Return
    -------
    s : valeurs de la fonction softmax appliquées à z ou de sa dérivée. Même dimension que z

    """ 
    exp_values = np.exp(z - np.max(z, axis=1, keepdims=True))
    
    s = exp_values / np.sum(exp_values, axis=1, keepdims=True)

    if deriv:
        return s * (1 - s)
    return s
