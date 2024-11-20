import codage as cd
import numpy as np
import plotly.graph_objs as go
import scipy.cluster.hierarchy as sch
import plotly.figure_factory as ff

def readfile(filename):
	with open(filename) as f:
		data = f.read().splitlines()

	return data


def acp(X, nom_individus, nom_variables, Xsup=[]):
    # Calcul de la matrice M (métrique)
    M = np.eye(X.shape[1])
    
    # Calcul de la matrice D (poid des individus)
    D = np.eye(X.shape[0]) / X.shape[0]
    
    # Calcul de la matrice de covariance pour les individus
    Xcov_ind = X.T.dot(D.dot(X.dot(M)))
    
    # Calcul des valeurs et vecteurs propres de la matrice de covariance
    L, U = np.linalg.eig(Xcov_ind)
    
    # Tri par ordre décroissant des valeurs des valeurs propres
    indices = np.argsort(L)[::-1]
    val_p_ind = np.sort(L)[::-1]
    vect_p_ind = U[:, indices]
    
    # Calcul des facteurs pour les individus 
    fact_ind = X.dot(M.dot(vect_p_ind))
    
    # Calcul des facteurs pour les variables actives (utilisation des relations de transition) 
    fact_var = X.T.dot(D.dot(fact_ind)) / np.sqrt(val_p_ind)
    

    # Calcul de la contribution des individus aux axes factoriels
    contributions_ind = np.zeros(fact_ind.shape)
    for i in range(fact_ind.shape[1]):
        f = fact_ind[:, i]
        contributions_ind[:, i] = 100 * D.dot(f*f) / f.T.dot(D.dot(f))
        
    print('Contribution des individus :')
    print(contributions_ind)

    # Calcul de la qualité de représentation des individus sur les axes factoriels
    distance = (fact_ind**2).sum(1)
    distance = distance.reshape(fact_ind.shape[0],1)
    
    qualite_ind = fact_ind**2 / distance
    
    print('Qualité de représentation des individus :')
    print(qualite_ind)
    
    # Calcul des pourcentage d'inertie des axes factoriels
    inerties = 100 * val_p_ind / val_p_ind.sum()
    
    print('Pourcentages d"inertie :')
    print(inerties)
    
    return fact_ind, fact_var

def cah(fact_ind, fact_var, k, nom_individus, noms_variables):
    Z = sch.linkage(fact_ind, 'ward')

    fig = go.Figure()
    dn = sch.dendrogram(Z)

    f = ff.create_dendrogram(fact_ind, orientation='right')
    f.show()


    # coupure en k clusters
    clusters = sch.fcluster(Z, k, criterion='maxclust')

    # dessin des clusters obtenus après la coupure
    fig.add_trace(go.Scatter(x=fact_ind[:, 0], y=fact_ind[:, 1], mode='markers+text', marker=dict(color=clusters),
                              text=nom_individus, textposition="top left", showlegend=False))
    
    # Pour représenter les variables sur les axes factoriels, on multiplie par 3 pour que ce soit plus lisible et pour qu'on voit mieux les distinctions entre les variables
    fig.add_trace(go.Scatter(x=3 * fact_var[:, 0], y=3 * fact_var[:, 1], mode='markers+text', marker=dict(color='black'),
                              text=nom_variables, textposition="top center", name="Variables"))

    fig.show()


if __name__ == '__main__' :
    # Lecture des données à partir des fichiers texte
    data = np.loadtxt('donnees/population_donnees.txt')
    nom_individus = readfile('donnees/population_noms_individus.txt')
    nom_variables = readfile('donnees/population_noms_variables.txt')
    
    data = cd.normalisation(data)
    
    X = data
    
    # Réalisation de l'ACP
    fact_ind, fact_var = acp(X, nom_individus, nom_variables)


    #  Affichage des individus et des variables sur les plans factoriels :
    # fig = go.Figure()
    # fig.add_trace(go.Scatter(x=fact_ind[:, 0], y=fact_ind[:, 1], mode="markers+text", marker=dict(color="black"), text=nom_individus, textposition="top center"))
    # fig.show()


    # Réalisation de la CAH
    k = 3
    cah(fact_ind, fact_var, k, nom_individus, nom_variables)    

