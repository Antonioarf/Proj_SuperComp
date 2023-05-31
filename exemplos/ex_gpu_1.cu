#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm> 
#include <random>
#include <chrono>
#include <stdlib.h> 
#include <iterator>
#include <random>
#include <chrono>
#include <fstream>
#include <bit>
#include <bitset>
#include <cstdint>
#include <stack>
#include <utility>
#include <map>
#include <ctime>
#include <omp.h>
#include <thrust/host_vector.h>
#include <thrust/sequence.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/functional.h>
#include <thrust/copy.h>
using std::vector;
using std::cin;
using std::cout;
using std::endl;
using std::bitset;
using std::map;
using std::stack;
using std::pair;
using std::make_pair;

struct Filme{
    int inicio;
    int fim;
    int categoria;
};


void preenche_horarios(int &horarios_disponiveis, int inicio, int fim){
    for (int i = 0; i < 24; i++){
        if (i >= inicio && i < fim){
            horarios_disponiveis  |= (1 << i);
        }
        else if (inicio > fim && (i >= inicio || i < fim)){
            horarios_disponiveis |= (1 << i);
        }
        else if(inicio == fim){
            horarios_disponiveis |= (1 << i);
        }
    }
}

struct busca_exaustiva_gpu 
{  
    int qtd_filmes;
    int qtd_categorias;
    int* filmes_por_categoria;
    int* horario_filmes;
    int* categoria_filmes;
    busca_exaustiva_gpu(int qtd_filmes_, int qtd_categorias_, int* filmes_por_categoria_, int* horario_filmes_, int* categoria_filmes_) : 
    qtd_filmes(qtd_filmes_), qtd_categorias(qtd_categorias_), filmes_por_categoria(filmes_por_categoria_), horario_filmes(horario_filmes_), categoria_filmes(categoria_filmes_) {}
    __host__ __device__
    int operator()(const int& config) {
        int horarios_disponiveis = 0;
        int filmes_por_categoria_aux[20];
        for (int i = 0; i < qtd_categorias; i++){
            filmes_por_categoria_aux[i] = *(filmes_por_categoria+i);
        }
        int num_filmes = 0;
        for (int i = 0; i < qtd_filmes; i++){
            if (config & (1 << i)){
                if (filmes_por_categoria_aux[categoria_filmes[i]-1] > 0){
                    int horario_analisado = horarios_disponiveis & *(horario_filmes + i);
                    if (((horario_analisado) != 0)) return false;
                    filmes_por_categoria_aux[categoria_filmes[i]-1]--;
                    horarios_disponiveis = horarios_disponiveis | *(horario_filmes + i);
                    num_filmes++;
                }
            }
        
        }

        return num_filmes;
    }
};



// int main(){
//     int qtd_filmes, qtd_categorias;
//     cin >> qtd_filmes >> qtd_categorias;

//     thrust::host_vector<int> filmes_por_categoria(qtd_categorias, 0);
//     Filme filme_vazio = {0, 0, 0};
//     vector<Filme> vetor_filmes (qtd_filmes, filme_vazio);

//     for (int i = 0; i < qtd_categorias; i++){
//         cin >> filmes_por_categoria[i];
//     }

//     for (int i = 0; i < qtd_filmes; i++){
//         Filme filme;
//         cin >> filme.inicio >> filme.fim >> filme.categoria;
//         if (filme.inicio == 0) filme.inicio = 24;
//         if (filme.fim == 0) filme.fim = 24;
//         if (filme.inicio < 0 || filme.fim < 0) continue;

//         vetor_filmes[i] = filme;
//     }

//     thrust::host_vector<int> categoria_filmes(qtd_filmes);
//     thrust::host_vector<int> horarios_filmes_cpu(qtd_filmes); 


//     for (int i = 0; i < qtd_filmes; i++){
//         horarios_filmes_cpu[i] = 0;
//         preenche_horarios(horarios_filmes_cpu[i], vetor_filmes[i].inicio-1, vetor_filmes[i].fim-1);
//         categoria_filmes[i] = vetor_filmes[i].categoria;
//     }

    thrust::device_vector<int> config_vector_gpu(pow(2, qtd_filmes));

    thrust::sequence(config_vector_gpu.begin(), config_vector_gpu.end());

    thrust::device_vector<int> categoria_filmes_gpu(categoria_filmes);
    thrust::device_vector<int> horarios_filmes_gpu(horarios_filmes_cpu);
    thrust::device_vector<int> filmes_por_categoria_gpu(filmes_por_categoria);

    thrust::transform(config_vector_gpu.begin(), config_vector_gpu.end(), config_vector_gpu.begin(), busca_exaustiva_gpu(qtd_filmes, qtd_categorias, raw_pointer_cast(filmes_por_categoria_gpu.data()), raw_pointer_cast(horarios_filmes_gpu.data()), raw_pointer_cast(categoria_filmes_gpu.data())));
    
    thrust::host_vector<int> config_vector_cpu_final = config_vector_gpu;
    
    int max_count = 0;
    int iters = pow(2, qtd_filmes);
    for (int i = 0; i < iters; i++){
        if (config_vector_cpu_final[i] > max_count){
            max_count = config_vector_cpu_final[i];
        }
    }

    cout << "Foram vistos " << max_count << " filmes." << endl;
}




// g++ -Wl,-z,stack-size=4194304 exaustiva.cpp -o exaustiva
//  g++ -Wl,-z,stack-size=6000000000 -fopenmp exaustiva.cpp -o exaustiva
// user@monstrinho:~/ProjetoSupercomp$ ./exaustiva 
// nvcc -arch=sm_70 -rdc=true -o exaustiva_thrust exaustiva_thrust.cu












#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sequence.h>
#include <thrust/transform.h>
#include <iostream>



int main() {
    // Dados de entrada
    int N = 3;
    int M = 2;
    thrust::host_vector<int> categories{1, 2, 2};
    thrust::host_vector<int> end_times{2, 4, 5};
    thrust::host_vector<int> start_times{1, 3, 4};
    thrust::host_vector<int> dp{(N+1) * (M+1), 0};
    thrust::host_vector<int> L{2, 1};

    // Transferir os dados para a GPU
    thrust::device_vector<int> categories_gpu = categories;
    thrust::device_vector<int> end_times_gpu = end_times;
    thrust::device_vector<int> start_times_gpu = start_times;
    thrust::device_vector<int> dp_gpu = dp;
    thrust::device_vector<int> L_gpu = L;

    // Criar a sequência de índices
    thrust::counting_iterator<int> first(0);
    thrust::counting_iterator<int> last = first + N * M;

    // Calcular o número máximo de filmes para cada combinação de i e j
    thrust::device_vector<int> result(N * M);
    thrust::transform(first, last, result.begin(), MaxFilmesFunctor(N, M, thrust::raw_pointer_cast(categories_gpu.data()), thrust::raw_pointer_cast(end_times_gpu.data()), thrust::raw_pointer_cast(start_times_gpu.data()), thrust::raw_pointer_cast(dp_gpu.data()), thrust::raw_pointer_cast(L_gpu.data())));

    // Copiar o resultado de volta para a CPU
    thrust::host_vector<int> result_cpu = result;

    // Encontrar o valor máximo
    int max_count = *thrust::max_element(result_cpu.begin(), result_cpu.end());

    // Imprimir o resultado
    std::cout << "Número máximo de filmes que podem ser assistidos: " << max_count << std::endl;

    return 0;
}
