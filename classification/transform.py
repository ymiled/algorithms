def transform(matrice, val):
    # renvoie une matrice qui remplace les 1 de la matrice argument par val

    sol = matrice.copy()

    for i in range(len(sol)):
        for j in range(len(sol[i])):
            if sol[i][j] == 1:
                sol[i][j] = val

    return sol
