import matplotlib.pyplot as plt
import numpy as np
from lecture_donnees import *
from normalisation import *
from decoupage_donnees import *
from passe_avant_classification import passe_avant
from passe_arriere_classification import passe_arriere
from sigmoide import *
from lineaire import *
from relu import *
from softmax import softmax
from calcul_cout_entropie_croisee import calcul_cout_entropie_croisee
from one_hot_encoding import one_hot_encoding

# ===================== Partie 1: Lecture et normalisation des données =====================
print("Lecture des données ...")

x, d, N, nb_var, nb_cible = lecture_donnees("donnees/notes.txt", type="classification")

# Affichage des 10 premiers exemples du dataset
print("Affichage des 10 premiers exemples du dataset : ")
for i in range(0, 10):
    print(f"x = {x[i,:]}, d = {d[i]}")
    
# Normalisation des variables (centrage-réduction)
print("Normalisation des variables ...")
x, mu, sigma = normalisation(x)
dmax = d.max()
d = d / dmax

# Découpage des données en sous-ensemble d'apprentissage, de validation et de test
x_app, d_app, x_val, d_val, x_test, d_test =  decoupage_donnees(x, d)


# ===================== Partie 2: Apprentissage =====================

# Choix du taux d'apprentissage et du nombre d'itérations
alpha = 0.001
nb_iters = 1000
couts_apprentissage = np.zeros(nb_iters)
couts_validation = np.zeros(nb_iters)

# Dimensions du réseau
D_c = [nb_var, 15, 10, nb_cible] # liste contenant le nombre de neurones pour chaque couche 
activation = [relu, relu, softmax] # liste contenant les fonctions d'activation des couches cachées et de la couche de sortie 

# Initialisation aléatoire des poids du réseau
W = []
b = []
for i in range(len(D_c) - 1):    
    W.append(2 * np.random.random((D_c[i + 1], D_c[i])) - 1)
    b.append(np.zeros((D_c[i + 1], 1)))


x_app = x_app.T # Les données sont présentées en entrée du réseau comme des vecteurs colonnes
d_app = d_app.T 

x_val = x_val.T 
d_val = d_val.T 

x_test = x_test.T 
d_test = d_test.T

for t in range(nb_iters):

    #############################################################################
    # Passe avant : calcul de la sortie prédite y sur les données de validation #
    #############################################################################
    a, h = passe_avant(x_val.T, W, b, activation)
    y_val = h[-1] # Sortie prédite

    ###############################################################################
    # Passe avant : calcul de la sortie prédite y sur les données d'apprentissage #
    ###############################################################################
    a, h = passe_avant(x_app.T, W, b, activation)
    y_app = h[-1] # Sortie prédite

    d_app_one_hot = one_hot_encoding(d_app, nb_cible)
    d_val_one_hot = one_hot_encoding(d_val, nb_cible)

    # print("y_app = ", y_app.shape)
    # print("d_app_one_hot = ", d_app_one_hot.shape)

    ###########################################
    # Calcul de la fonction perte de type Entropie croisée #
    ###########################################
    couts_apprentissage[t] = calcul_cout_entropie_croisee(y_app, d_app_one_hot)
    couts_validation[t] = calcul_cout_entropie_croisee(y_val, d_val_one_hot)

    ####################################
    # Passe arrière : rétropropagation #
    ####################################
    delta_h = (y_app - d_app_one_hot) # Pour la dernière couche 

    delta_W, delta_b = passe_arriere(delta_h, a, h, W, activation)
  
    #############################################
    # Mise à jour des poids et des biais  ##### #
    ############################################# 
    for i in range(len(b)-1,-1,-1):
        b[i] -= alpha * delta_b[i]
        W[i] -= alpha * delta_W[i]

print("Coût final sur l'ensemble d'apprentissage : ", couts_apprentissage[-1])
print("Coût final sur l'ensemble de validation : ", couts_validation[-1])


# Affichage de l'évolution de la fonction de cout lors de la rétropropagation
plt.figure(0)
plt.title("Evolution de le fonction de coût lors de la retropropagation")
plt.plot(np.arange(couts_apprentissage.size), couts_apprentissage, label="Apprentissage")
plt.plot(np.arange(couts_validation.size), couts_validation, label="Validation")
plt.legend(loc="upper left")
plt.xlabel("Nombre d'iterations")
plt.ylabel("Coût")


# ===================== Partie 3: Evaluation sur l'ensemble de test =====================

#######################################################################
# Passe avant : calcul de la sortie prédite y sur les données de test #
#######################################################################


a, h = passe_avant(x_test.T, W, b, activation)


y_test = h[-1] # Sortie prédite
cout = calcul_cout_entropie_croisee(y_test, one_hot_encoding(d_test, nb_cible))
print("Coût sur l'ensemble de test : ", cout)

print(y_test)

dmax = d_test.max()
y_pred = np.argmax(y_test, axis=1) / dmax

print("y_pred = ", y_pred)
print("d_test = ", d_test)

print("Précision = ", np.sum(y_pred == d_test) / d_test.shape[1])
plt.show()