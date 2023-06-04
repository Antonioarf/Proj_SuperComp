#include <thrust/generate.h>
#include <thrust/functional.h>
#include <thrust/copy.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sequence.h>
#include <thrust/transform.h>
#include <thrust/execution_policy.h>
#include <thrust/extrema.h>
#include <chrono>
#include <iostream>

using namespace std;



struct MaxFilmesFunctor {
    int n_filmes; // Number of filmes (movies)
    int n_cat; // Number of categories
    int* categories;
    int* end_times;
    int* start_times;
    int* dp;
    int* L;

    MaxFilmesFunctor(int n_filmes, int n_cat, int* categories, int* end_times, int* start_times, int* dp, int* L) : 
    n_filmes(n_filmes), n_cat(n_cat), categories(categories), end_times(end_times), start_times(start_times), dp(dp), L(L) {}

    __device__
    int operator()() {


        for (int i = 1; i <= n_filmes; i++) {
        for (int j = 1; j <= n_cat; j++) {
            // Encontrar o número máximo de filmes que podem ser assistidos até o filme i e categoria j
            int max_count = 0;
            for (int k = 0; k < i; k++) {
            if (categories[k] == j && end_times[k] <= start_times[i] && dp[(k*(n_cat+1)) + j-1] + 1 <= L[j-1]) {
                max_count = max(max_count, dp[(k*(n_cat+1)) + j-1] + 1);
            } else {
                max_count = max(max_count, dp[(k*(n_cat+1)) + j]);
            }
            }
            dp[(i*(n_cat+1)) + j] = max_count;
        }
        }
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
        categories[conta] = (i3-1);
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
thrust::counting_iterator<int> last = first + n_filmes * n_cat;




thrust::device_vector<int> result(n_filmes * n_cat, 0);

thrust::transform(thrust::device,
                  thrust::make_counting_iterator(0),
                  thrust::make_counting_iterator(n_filmes * n_cat),
                  result.begin(),
                  MaxFilmesFunctor(n_filmes, n_cat,
                                    raw_pointer_cast(categories_gpu.data()),
                                    raw_pointer_cast(end_times_gpu.data()),
                                    raw_pointer_cast(start_times_gpu.data()),
                                    raw_pointer_cast(dp_gpu.data()),
                                    raw_pointer_cast(L_gpu.data())));
    // Encontrar o número máximo de filmes que podem ser assistidos
int max_count = 0;
// for (int j = 1; j <= n_cat; j++) {
//   max_count = max(max_count, dp[(n_filmes*(n_cat+1)) + j]);
// }
    

    ///// FIM DO TIMER
auto after = chrono::high_resolution_clock::now();
auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

cout << delta<< " , " << n_filmes<< " , " << n_cat<< " , "<< max_count<< "\n";
}
