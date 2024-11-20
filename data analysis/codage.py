import numpy as np

def normalisation(matrice):
    matrice_moyennes = np.mean(matrice, axis=0)
    ecarts_types = np.std(matrice, axis=0)

    return (matrice - matrice_moyennes) / ecarts_types

test_matrice = np.array([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [10, 11, 12],
    [13, 14, 15], 
    [16, 17, 18]
])

matrice_test = np.array([
    ['Petit', 'Rouge', 'Femme'],
    ['Moyen', 'Blanc', 'Homme'],
    ['Grand', 'Rouge', 'Femme'],
    ['Moyen', 'Blanc', 'Homme'],
    ['Petit', 'Rouge', 'Femme']
])


def quantitatif_en_qualitatif1(matrice, nb_intervalles):
    n, p = matrice.shape
    matrice_solution = np.zeros((n, p))

    for j in range(p):
        mini = np.min(matrice[:, j])
        maxi = np.max(matrice[:, j])
        taille_intervalle = (maxi - mini) / nb_intervalles

        for i in range(n):
            value = matrice[i, j]
            for k in range(nb_intervalles):
                print(value, mini + k * taille_intervalle, mini + (k + 1) * taille_intervalle)
                if value >= mini + k * taille_intervalle and value < mini + (k + 1) * taille_intervalle:
                    matrice_solution[i, j] = k
                    break

            if value == maxi:
                matrice_solution[i, j] = nb_intervalles - 1

    return matrice_solution

def quantitatif_en_qualitatif2(matrice, nb_intervalles):
    # découpage des variables quantitatives en effectifs égaux 
    n, p = matrice.shape
    matrice_solution = np.zeros((n, p))
    for j in range(p):
        sorted_col = np.sort(matrice[:, j])
        mini = np.min(sorted_col)
        maxi = np.max(sorted_col)

        for i in range(n):
            value = matrice[i, j]
            for k in range(nb_intervalles):
                if value >= np.quantile(sorted_col, k/nb_intervalles) and value < np.quantile(sorted_col, (k + 1)/nb_intervalles):
                    matrice_solution[i, j] = k
                    break

            if value == maxi:
                matrice_solution[i, j] = nb_intervalles - 1

    return matrice_solution
    # np.argsort -> donne indice des valeurs triées


def contingence(matrice):
    # construction tableau de Brut
    n, p = matrice.shape
    matrice_contingence = np.zeros((n, p))
    modalites = np.unique(matrice)
  
    dico = [[ {modalite: 0 for modalite in modalites}] for i in range(n)]

    for i in range(n):
        print(dico[i])
        for j in range(p):
            for modalite in modalites:
                if matrice[i, j] == modalite:
                    if modalite not in dico[i]:
                        dico[i][modalite] = 1
                    else:
                        dico[i][modalite] = dico[i][modalite] + 1

    for i in range(n):
        for j in range(p):
            matrice_contingence[i, j] = dico[i][matrice[i, j]]

    return  matrice_contingence








def contingence(matrice):    
    n, p = matrice.shape
    modalités_par_variable = [np.unique(matrice[:, j]) for j in range(p)]
    
    taille_totale = sum([len(modalités) for modalités in modalités_par_variable])
    
    tableau_contingence = np.zeros((taille_totale, taille_totale))
    
    index_debut = 0
    index_par_variable = []
    
    for modalités in modalités_par_variable:
        index_par_variable.append((index_debut, index_debut + len(modalités)))
        index_debut += len(modalités)
    
    for i in range(p):
        for j in range(i, p):
            for ind in range(n):
                modalite_i = matrice[ind, i]
                modalite_j = matrice[ind, j]
                
                # Indices des modalités dans le tableau de contingence
                index_i = np.where(modalités_par_variable[i] == modalite_i)[0][0] + index_par_variable[i][0]
                index_j = np.where(modalités_par_variable[j] == modalite_j)[0][0] + index_par_variable[j][0]
                
                # Incrémenter les deux positions symétriques
                tableau_contingence[index_i, index_j] += 1
                if i != j:
                    tableau_contingence[index_j, index_i] += 1

    return tableau_contingence












def affichage(matrice, noms):
    if matrice.shape[1] != 2:
        raise ValueError("La matrice doit avoir exactement deux colonnes pour les variables quantitatives.")
    if len(noms) != matrice.shape[0]:
        raise ValueError("Le nombre de noms doit correspondre au nombre d'individus dans la matrice.")
    
    largeur = 40
    hauteur = 20
    
    x_min, x_max = np.min(matrice[:, 0]), np.max(matrice[:, 0])
    y_min, y_max = np.min(matrice[:, 1]), np.max(matrice[:, 1])
    
    plan = [[' ' for _ in range(largeur)] for _ in range(hauteur)]
    
    for i, nom in enumerate(noms):
        x = int((matrice[i, 0] - x_min) / (x_max - x_min) * (largeur - 1))
        y = int((matrice[i, 1] - y_min) / (y_max - y_min) * (hauteur - 1))
        plan[hauteur - 1 - y][x] = nom[0]  # Utiliser la première lettre du nom
    
    for ligne in plan:
        print(''.join(ligne))




if __name__ == "__main__":
    data = np.loadtxt('TD1-donnees/vins.txt')
    #print(normalisation(data))
    print(data)
    print(quantitatif_en_qualitatif2(data, 3))
    print(contingence(matrice_test))
    
