import numpy as np
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import fcluster, linkage, dendrogram
from scipy.cluster.vq import kmeans2
import random

def quantitatif_en_qualitatif1(m,nb_intervalles):
    mmin = m.min(0)
    mmax = m.max(0)
    taille_intervalles = (mmax - mmin) / nb_intervalles
    bornes = mmin
    for i in range(1,nb_intervalles):
        bornes = np.vstack((bornes, mmin + i*taille_intervalles))
    bornes = np.vstack((bornes,mmax))
    mqual = np.zeros(m.shape,dtype='int')
    for i in range(m.shape[0]):
        for j in range(m.shape[1]):
            k = 0
            trouve = False
            while not trouve:
                if bornes[k,j] <= m[i,j] <= bornes[k+1,j]:
                    trouve = True
                    mqual[i,j] = k
                k += 1
    return mqual


def readfile(filename):
    with open(filename) as f:
        data = f.read().splitlines()

    return data


def acm(data,noms_individus,noms_variables):

    nb_modalites_par_var = data.max(0)
    nb_modalites = int(nb_modalites_par_var.sum())

    XTDC = np.zeros((data.shape[0],nb_modalites))
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            XTDC[i, int(nb_modalites_par_var[:j].sum() + data[i,j]-1)] = 1

    noms_modalites = []
    for i in range(data.shape[1]):
        for j in range(int(nb_modalites_par_var[i])):
            noms_modalites.append(noms_variables[i]+str(j+1))

    print(noms_modalites)


    Xfreq = XTDC / XTDC.sum()

    marge_colonne = Xfreq.sum(1).reshape(Xfreq.shape[0],1)
    # print(marge_colonne.shape)
    marge_ligne = Xfreq.sum(0).reshape(1,Xfreq.shape[1])
    # print(marge_ligne.shape)

    Xindep = marge_ligne * marge_colonne
    # print(Xindep.shape)


    X = Xfreq / Xindep - 1

    M = np.diag(marge_ligne[0,:])
    D = np.diag(marge_colonne[:,0])
    # print(M.shape)
    # print(D.shape)

    # Calcul de la matrice de covariance pour les modalités en ligne
    Xcov_ind = X.T.dot(D.dot(X.dot(M)))

    # Calcul des valeurs et vecteurs propres de la matrice de covariance
    L,U = np.linalg.eig(Xcov_ind)

    # Tri par ordre décroissant des valeurs des valeurs propres
    indices = np.argsort(L)[::-1]
    print(type(indices))
    val_p_ind = np.float16(np.sort(L)[::-1]) # car des valeurs peuvent être complexes avec une partie imaginaire nulle en raison d'approximations numériques
    vect_p_ind = U[:,indices]

    # Suppression des éventuelles valeurs propres nulles
    indices = np.nonzero(val_p_ind > 0)[0]
    print(type(indices))
    val_p_ind = val_p_ind[indices]
    vect_p_ind = vect_p_ind[:,indices]

    # Calcul des facteurs pour les modalités en ligne
    fact_ind = np.real(X.dot(M.dot(vect_p_ind)))

    # Calcul des facteurs pour les modalités en colonne
    fact_mod = X.T.dot(D.dot(fact_ind)) / np.sqrt(val_p_ind)

    # Calcul des pourcentage d'inertie des axes factoriels
    inerties = 100*val_p_ind / val_p_ind.sum()

    print('Valeurs propres :')
    print(val_p_ind)

    print('Pourcentages d"inertie :')
    print(inerties)

    # Affichage du diagramme d'inertie
    plt.figure(1)
    plt.plot(inerties,'o-')
    plt.title('Diagramme des inerties')


    # Calcul de la contribution des individus
    contributions_ind = np.zeros(fact_ind.shape)
    for i in range(fact_ind.shape[1]):
        f = fact_ind[:,i]
        contributions_ind[:,i] = 100 * D.dot(f*f) / f.T.dot(D.dot(f))

    print('Contribution des individus :')
    print(contributions_ind)

    # Calcul de la contribution des modalités
    contributions_mod = np.zeros(fact_mod.shape)
    for i in range(fact_mod.shape[1]):
        f = fact_mod[:,i]
        contributions_mod[:,i] = 100 * M.dot(f*f) / f.T.dot(M.dot(f))

    print('Contribution des modalités :')
    print(contributions_mod)

    # Calcul de la qualité de représentation des modalités en ligne
    distance = (fact_ind**2).sum(1)
    distance = distance.reshape(fact_ind.shape[0],1)

    qualite_ind = fact_ind**2 / distance

    print('Qualité de représentation des individus :')
    print(qualite_ind)

    # Calcul de la qualité de représentation des modalités
    distance = (fact_mod**2).sum(1)
    distance = distance.reshape(fact_mod.shape[0],1)

    qualite_mod = fact_mod**2 / distance

    print('Qualité de représentation des modalités :')
    print(qualite_mod)

    # Affichage du plan factoriel pour les indidivus
    plt.figure(2)
    plt.plot(fact_ind[:,0],fact_ind[:,1],'x')
    plt.grid(True)
    plt.axvline(linewidth=0.5,color='k')
    plt.axhline(linewidth=0.5,color='k')
    plt.title('ACM Projection des individus')
    for label,x,y in zip(noms_individus,fact_ind[:,0],fact_ind[:,1]):
        plt.annotate(label,
                      xy=(x,y),
                      xytext=(-50,5),
                      textcoords="offset points",
                      arrowprops=dict(arrowstyle='->',connectionstyle='arc3,rad=0')
                      )

    # Affichage du plan factoriel pour les modalités en colonne
    plt.figure(3)
    plt.plot(fact_mod[:,0],fact_mod[:,1],'x')
    plt.grid(True)
    plt.axvline(linewidth=0.5,color='k')
    plt.axhline(linewidth=0.5,color='k')
    plt.title('ACM Projection des modalités')
    for label,x,y in zip(noms_modalites,fact_mod[:,0],fact_mod[:,1]):
        plt.annotate(label,
                     xy=(x,y),
                     xytext=(-50,5),
                     textcoords="offset points",
                     arrowprops=dict(arrowstyle='->',connectionstyle='arc3,rad=0')
                     )
    plt.show()
    return fact_ind


# CAH après ACM
def cah(X, noms_individus):
    # Calcul de la matrice de liaison avec la méthode 'average' au lieu de 'ward'
    Z = linkage(X, method='average')

    # Création de la figure du dendrogramme avec une configuration différente
    plt.figure(figsize=(15, 12))
    dendrogram(
        Z,
        orientation='right',
        labels=noms_individus,
        distance_sort='ascending',  # Tri par ordre ascendant des distances
        show_leaf_counts=False
    )

    # Nombre de clusters fixé à 3 au lieu de découper selon un seuil
    k = 3
    clusters = fcluster(Z, k, criterion='maxclust')

    # Affichage des individus avec leurs clusters
    plt.figure(figsize=(10, 8))
    plt.plot(d1, d2, 'x', color='black')
    plt.grid(True)
    plt.title('ACM + CAH')
    plt.scatter(d1, d2, c=clusters)

    # Annotation des points
    for label, x, y in zip(noms_individus, d1, d2):
        plt.annotate(label, xy=(x, y), xytext=(-10, 2), textcoords="offset points",
                     arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=0'))
    plt.show()

#Centres Mobiles
def cm(X, noms_individus, q=4):
    # Initialisation des centres avec l'option 'points' et un nombre d'itérations de 15
    centroids, labels = kmeans2(X, q, iter=15, minit='points')

    # Affichage des individus dans le plan factoriel
    plt.plot(d1, d2, 'x', color='black')
    plt.grid(True)
    plt.title('ACM + Centres Mobiles')
    for label, x, y in zip(noms_individus, d1, d2):
        plt.annotate(label, xy=(x, y), xytext=(-10, 2), textcoords="offset points",
                     arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=0'))

    # Affichage des clusters avec les centres
    w = [[] for k in range(q)]
    for i in range(q):
        w[i] = X[labels == i]
        # Couleur aléatoire pour chaque cluster
        c = "#"+''.join([random.choice('0123456789ABCDEF') for j in range(6)])
        plt.plot(w[i][:, 0], w[i][:, 1], 'o', alpha=0.5, label=f'cluster {i+1}', color=c)
        plt.plot(centroids[i, 0], centroids[i, 1], label='centroids', color=c)

    plt.show()
    
    
    
if __name__ == '__main__' :

    # Lecture des données à partir des fichiers texte
    data = np.loadtxt('donnees/population_donnees.txt')
    noms_individus = readfile('donnees/population_noms_individus.txt')
    noms_variables = readfile('donnees/population_noms_variables.txt')
    # Normalisation des données
    X = quantitatif_en_qualitatif1(data,3) + 1

    # Réalisation de l'acp
    fact_ind = acm(X, noms_individus, noms_variables)

    #On construit ensuite la matrice des distances
    d1 = fact_ind[:,0]
    d2 = fact_ind[:,1]
    n = d1.size
    distance = np.zeros((n,n))
    for i in range(n):
        for j in range(n):
            distance[i,j]= np.sqrt((d1[j]-d1[i])**2+(d2[j]-d2[i])**2)
    #On met cette matrice au bon format (comme elle est symétrique -> on la transforme en vecteur)
    X1 = distance[np.triu_indices(n,1)]

    cah(X1, noms_individus)


    #On créé un matrice composé de deux colonnes que sont les les coordonnées des individus dans le plan factoriel
    X2 = np.zeros((n,2))
    for i in range(n):
        X2[i,0] = d1[i]
        X2[i,1] = d2[i]

    cm(X2, noms_individus)










