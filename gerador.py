import os
import itertools
import numpy as np

filmes =np.arange(45000, 62500, 2500).tolist()
cats = list(range(5,26))
inps = itertools.product(filmes,cats)
os.system(f'g++ -Wall -O3 gerador.cpp -o gerador')
print(len(cats)*len(filmes))
for e in inps:
     os.system('./gerador {} {}'.format(e[0],e[1]))
#os.system('./gerador {} {}'.format(1000,5))