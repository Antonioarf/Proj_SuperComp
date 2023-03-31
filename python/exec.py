import os
import subprocess
import time


entries = os.listdir('input/')
algotimo = 'aleatoria_invertida'
os.system(f'g++ -Wall -O3 {algotimo}.cpp -o {algotimo}')
for inp in entries:
    with open(f'input/{inp}') as f:
        proc = subprocess.run(["./{}".format(algotimo)], input=f.read(), text=True, capture_output=True)
        #print('Saída:', proc.stdout)

    with open('output/{}/out_{}_{}.txt'.format(algotimo,algotimo,inp[6:-4]), 'w') as f:
        f.write(proc.stdout)
        

