#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sequence.h>
#include <thrust/transform.h>
#include <chrono>
#include <iostream>
using namespace std;



struct MaxFilmesFunctor {
    int N;
    int M;
    const int* categories;
    const int* end_times;
    const int* start_times;
    const int* dp;
    const int* L;

    MaxFilmesFunctor(int N_, int M_, const int* categories_, const int* end_times_, const int* start_times_, const int* dp_, const int* L_) :
        N(N_), M(M_), categories(categories_), end_times(end_times_), start_times(start_times_), dp(dp_), L(L_) {}

    __host__ __device__
    int operator()(const thrust::tuple<int, int>& indices) {
        int i = thrust::get<0>(indices) + 1;
        int j = thrust::get<1>(indices) + 1;

        // Encontrar o número máximo de filmes que podem ser assistidos até o filme i e categoria j
        int max_count = 0;
        for (int k = 0; k < i; k++) {
            if (categories[k] == j && end_times[k] <= start_times[i] && dp[(k*(M+1)) + j-1] + 1 <= L[j-1]) {
                max_count = max(max_count, dp[(k*(M+1)) + j-1] + 1);
            } else {
                max_count = max(max_count, dp[(k*(M+1)) + j]);
            }
        }

        return max_count;
    }
};


int main(){

// Carregar os dados do arquivo de entrada na memória da GPU


// Ler os dados do arquivo de entrada
int  n_cat;
int n_filmes;
int conta = 0;
int lim;
vector<int> limites;
cin >> n_filmes >> n_cat;


thrust::host_vector<int> start_times(n_filmes);
thrust::host_vector<int> end_times(n_filmes);
thrust::host_vector<int> categories(n_filmes);
thrust::host_vector<int> L(n_cat);
while(conta<n_cat){
        cin >> lim;
        L[conta] = lim;
        conta++;
    }

conta = 0;
int i1, i2, i3;
while(conta<n_filmes){
        cin >> i1 >> i2 >> i3;
        start_times[conta] = i1;
        end_times[conta] = i2;
        categories[conta] = i3;
        conta++;
    }




auto before = std::chrono::high_resolution_clock::now();

thrust::host_vector<int> dp{(n_filmes+1) * (n_cat+1), 0};
thrust::device_vector<int> dp_gpu = dp;

thrust::device_vector<int> categories_gpu = categories;
thrust::device_vector<int> end_times_gpu = end_times;
thrust::device_vector<int> start_times_gpu = start_times;
thrust::device_vector<int> L_gpu = L;

// Criar a sequência de índices
thrust::counting_iterator<int> first(0);
thrust::counting_iterator<int> last = first + N * M;




thrust::device_vector<int> result(n_filmes * n_cat);
thrust::transform(first, last, result.begin(), MaxFilmesFunctor(n_filmes,n_cat, thrust::raw_pointer_cast(categories_gpu.data()), thrust::raw_pointer_cast(end_times_gpu.data()), thrust::raw_pointer_cast(start_times_gpu.data()), thrust::raw_pointer_cast(dp_gpu.data()), thrust::raw_pointer_cast(L_gpu.data())));

// Copiar o resultado de volta para a CPU
thrust::host_vector<int> result_cpu = result;


int max_count = *thrust::max_element(result_cpu.begin(), result_cpu.end());

    

    ///// FIM DO TIMER
auto after = chrono::high_resolution_clock::now();
auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

cout << "Time: " << delta << "\n";
cout << "N_filmes " << n_filmes << "\n";
cout << "N_cat " << n_cat << "\n";
cout << "TAMANHO " << max_count << "\n";
}

