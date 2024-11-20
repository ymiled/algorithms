import matplotlib.pyplot as plt
import numpy as np


def affichage(X, Y, k, classes, name_axe1="x1", name_axe2="x2"):
    """ Affichage en 2 dimensions des données (2 dimensions de X) et représentation de la 
        classe (indiquée par Y) par une couleur
    

    Parametres
    ----------
    X : matrice des données de dimension [N, nb_var+1]
    Y : matrice contenant les valeurs de la variable cible de dimension [N, 1]
    k : nombre de classes
    
    avec N : nombre d'éléments et nb_var : nombre de variables prédictives

    Retour
    -------
    None

    """

    # Affichage des points en 2D et représentation de leur classe réelle par une couleur
    colors = ['red', 'blue', 'green', 'black', 'yellow', 'cyan', 'magenta', 'orange', 'purple', 'brown']

    for i in range(k):
        plt.scatter(X[Y[:, 0] == classes[i], 0], X[Y[:, 0] == classes[i], 1], color=colors[i], marker='o', label=f'Classe {i}')
        plt.xlabel(name_axe1)
        plt.ylabel(name_axe2)
        plt.legend()