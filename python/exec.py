import os
import subprocess
from pathlib import Path
import time
import csv

pai = (Path(__file__).parent).parent
entries = (list(os.listdir(f"{pai}/input")))
cpps = f"{pai}/CPP/"
# algos  = ["exaustiva","exaustiva_paralela","aleatoria","aleatoria_invertida","gulosa","gulosa_invertida","dinamica_gpu" ]
algos = ["dinamica_gpu"]
output=""
for algo in algos:
    # print(f"Compilando {algo}")
    output+=f"Rodando {algo}\n"
    start = time.time()
    if algo == "exaustiva_paralela":
        os.system(f'g++ -Wall -fopenmp -O3 {cpps}/{algo}.cpp -o {pai}/CPP/{algo}')
    elif algo == "dinamica_gpu":
        os.system(f'nvcc -arch=sm_70 -std=c++14 {cpps}/{algo}.cu -o {pai}/CPP/{algo}')
    else:
        os.system(f'g++ -Wall -O3 {cpps}/{algo}.cpp -o {pai}/CPP/{algo}')
    t1 = time.time()
    # print(f"Tempo de compilação: {t1-start}")
    # output+=f"Tempo de compilação: {t1-start}\n"
    print(f"Executando {algo}")
    open('{}/output/{}.csv'.format(pai,algo), 'w').close()

    for inp in entries:
        with open(f'{pai}/input/{inp}') as f:
            proc = subprocess.run([f"./CPP/{algo}"], input=f.read(), text=True, capture_output=True)

        with open('{}/output/{}.csv'.format(pai,algo), 'a') as f:
            f.write(proc.stdout)

    print(f"Tempo de execução: {time.time()-t1}")
    output+=f"Tempo de execução: {time.time()-t1}\n"

with open(f'{pai}/output/tempos.txt', 'w') as f:
    f.write(output)

