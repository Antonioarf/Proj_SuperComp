import os
import subprocess
from pathlib import Path


pai = (Path(__file__).parent).parent
entries = os.listdir(f"{pai}/input")
cpps = f"{pai}/CPP/"
# algos  = ["gulosa","gulosa_invertida","aleatoria","aleatoria_invertida","exaustiva_paralela","exaustiva"]
algos = ["exaustiva_paralela"]
for algo in algos:
    if algo == "exaustiva" or algo == "exaustiva_paralela":
        os.system(f'g++ -Wall -fopenmp -O3 {cpps}/{algo}.cpp -o {pai}/CPP/{algo}')
    else:
        os.system(f'g++ -Wall -O3 {cpps}/{algo}.cpp -o {pai}/CPP/{algo}')
    
    print(algo)
    for inp in entries:
        with open(f'{pai}/input/{inp}') as f:
            proc = subprocess.run([f"./CPP/{algo}"], input=f.read(), text=True, capture_output=True)
            #print('Saída:', proc.stdout)
        with open('{}/output/{}/out_{}_{}.txt'.format(pai,algo,algo,inp[6:-4]), 'w') as f:
            f.write(proc.stdout)
    
