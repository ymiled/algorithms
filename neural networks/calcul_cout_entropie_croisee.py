import numpy as np

import numpy as np

def calcul_cout_entropie_croisee(y, d):
    """
    Calculate the cross-entropy cost for multiple samples.

    Parameters:
    y (array-like): True labels (one-hot encoded or probability distribution), shape (n_samples, n_classes).
    d (array-like): Predicted probabilities, shape (n_samples, n_classes).

    Returns:
    float: Total cross-entropy cost.
    """

    # Number of samples
    n = y.shape[0]

    # Calculate the cross-entropy cost
    # add a small value to avoid log(0)

    cost = -np.sum(d * np.log(y + 1e-11)) / n

    return cost
