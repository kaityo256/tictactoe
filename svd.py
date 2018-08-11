import math
from scipy import linalg
import numpy as np

def svd(B, d):
    U, s, V = linalg.svd(B)

    S1 = np.zeros((27, 27), dtype="float64")
    S1[:27, :27] = np.diag([math.sqrt(v) for v in s])
    S2 = np.zeros((27, 6561), dtype="float64")
    S2[:27, :27] = np.diag([math.sqrt(v) for v in s])

    L = U.dot(S1)[:, :d]
    V1 = S2.dot(V)[:d, :]

    V1 = V1.reshape((d, 27, 27, 9))
    V1 = V1.transpose([0, 1, 3, 2])
    V1 = V1.reshape((d*27*9, 27))
    U, s, V = linalg.svd(V1)

    S1 = np.zeros((d*3**3*9, 27), dtype="float64")
    S1[:27, :27] = np.diag([math.sqrt(v) for v in s])
    S2 = np.zeros((27, 27), dtype="float64")
    S2[:27, :27] = np.diag([math.sqrt(v) for v in s])

    C = U.dot(S1)[:, :d]
    R = S2.dot(V)[:d, :]

    CR = C.dot(R)
    CR = CR.reshape((d, 27, 9, 27))
    CR = CR.transpose([0, 1, 3, 2])

    X = np.tensordot(L, CR, axes=([1], [0]))
    X = X.reshape((27, 6561))
    return X

A = np.fromfile("data.dat", dtype="float64")
B = A.reshape((27, 6561))

for d in range(27, 13, -1):
    X = svd(B, d)
    r = linalg.norm(X-B) / linalg.norm(B)
    print "{0} {1}".format(d, r)
