import numpy as np 

def one_hot_encoding(tab, n):
    """
    Fonction qui encode une liste de valeurs en one-hot encoding :
    Chaque ligne est représentée par un vecteur avec un 1 dans 
    la position correspondant à cette catégorie et des 0 dans toutes 
    les autres positions
    """

    tab_encod = np.zeros((tab.shape[1], n))
    unique = np.unique(tab)
    for i in range(tab.shape[1]):
        val = tab[0][i]
        for j in range(n):
            if val == unique[j]:
                tab_encod[i, j] = 1

    return tab_encod