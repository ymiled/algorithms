import matplotlib.pyplot as plt
import numpy as np
from lecture_donnees import *
from normalisation import *
from descente_gradient import *
from affichage import *
from prediction import *
from taux_classification import *
from decoupage_donnees import decoupage
from transform import transform

prop_app = 0.7
prop_test = 1 - prop_app

# ===================== Partie 1: Lecture et normalisation des données=====================
print("Lecture des données ...")

X, Y, N, nb_var = lecture_donnees("donnees/digit_writing.txt", delimiteur=',', is_csv=False)
# X, Y, N, nb_var = lecture_donnees("donnees/white_wine_quality.csv", delimiteur=';', is_csv=True)

X, mu, sigma = normalisation(X)

# Ajout d'une colonne de 1 à X (pour theta0)
X = np.hstack((np.ones((N,1)), X))

# Découpage des données en sous-ensemble d'apprentissage et de test
X_app, Y_app, X_test, Y_test = decoupage(X, Y, prop_app=prop_app)

unique_values = np.unique(Y)

k = len(unique_values)
Y_i = [Y_app for i in range(k)]


# ===================== Partie 2: Descente du gradient =====================
print("Apprentissage par descente du gradient ...")

# theta est une liste de k liste vides
theta = [np.zeros((1, nb_var + 1)) for i in range(k)]
J_history = [[] for i in range(k)]

# Choix du taux d'apprentissage et du nombre d'itérations
alpha = 0.01
nb_iters = 5000

for i in range(k):
    # On crée un nouveau Y_i tel que Y_i = 1 si Y = i et Y_i = 0 sinon
    Y_i[i] = np.where(Y_app == unique_values[i], 1, 0)

    # Initialisation de theta et réalisation de la descente du gradient
    theta[i], J_history[i] = descente_gradient(X_app, Y_i[i], theta[i], alpha, nb_iters)

    # Affichage de l'évolution de la fonction de cout lors de la descente du gradient
    # plt.figure(i + 2)
    # plt.title("Evolution de le fonction de cout lors de la descente du gradient")
    # plt.plot(np.arange(J_history[i].size), J_history[i])
    # plt.xlabel("Nombre d'iterations")
    # plt.ylabel("Cout J")

    # Affichage de la valeur de theta
    print(f"Theta calculé par la descente du gradient pour la classe {unique_values[i]}: {theta[i]}")
       
echantillon = "test"

if echantillon == 'apprentissage':
    X_manip = X_app
    Y_manip = Y_app
    n = Y_app.shape[0]
else:
    X_manip = X_test
    Y_manip = Y_test
    n = Y_test.shape[0]

Ypred = [transform(prediction(X_manip, theta[i]), unique_values[i]) for i in range(k)]
new_Y = np.zeros((n, 1))
for i in range(n):
    max_proba = 0
    for j in range(k):
        f = sigmoide(np.dot(X_manip, theta[j].T))
        if f[i] > max_proba:
            max_proba = f[i]
            new_Y[i] = unique_values[j]

            
print("Taux de classification : ", taux_classification(new_Y, Y_manip))


# Affichage des résultats avec les données non normalisées
X_denorm = X_manip[:, 1:] * sigma + mu

if nb_var == 2:
    plt.figure(1)
    plt.title(f"Disposition des données brutes en 2D sur l'ensemble de {echantillon}")
    affichage(X_denorm, Y_manip, k, classes = unique_values, name_axe1="x1", name_axe2="x2")

    plt.figure(2)
    plt.title(f"Disposition des points de l'ensemble de {echantillon} après prédiction")
    affichage(X_denorm, new_Y, k, classes=unique_values, name_axe1="x1", name_axe2="x2")

plt.show()




