import numpy as np
import csv


def lecture_donnees(nom_fichier, delimiteur=',', is_csv=False):
    """ Lit le fichier contenant les données et renvoiee les matrices correspondant

    Parametres
    ----------
    nom_fichier : nom du fichier contenant les données
    delimiteur : caratère délimitant les colonne dans le fichier ("," par défaut)

    Retour
    -------
    X : matrice des données de dimension [N, nb_var]
    Y : matrice contenant les valeurs de la variable cible de dimension [N, 1]
    
    avec N : nombre d'éléments et nb_var : nombre de variables prédictives

    """
    if is_csv:
        with open(nom_fichier, 'r') as csv_file:
            csv_reader = csv.reader(csv_file)

            # Ecriture des données sur un fichier txt
            nom_fichier = nom_fichier.replace('.csv', '.txt')
            with open(nom_fichier, 'w') as txt_file:
                for i, row in enumerate(csv_reader):
                    if i == 0:
                        nb_var = len(row) - 1
                    else:
                        txt_file.write(",".join(row) + "\n")


    # Lecture des données
    data = np.loadtxt(nom_fichier, delimiter=delimiteur, dtype=object)
    nb_var = data.shape[1] - 1
    N = data.shape[0]
    X = data[:, 0:nb_var].astype(float)
    Y = data[:, nb_var].reshape(N, 1)

    unique_values = np.unique(Y)
    mapping = {unique_values[i]: i for i in range(len(unique_values))}
    Y = np.array([mapping[Y[i, 0]] for i in range(N)]).reshape(N, 1)

    
    return X, Y, N, nb_var


