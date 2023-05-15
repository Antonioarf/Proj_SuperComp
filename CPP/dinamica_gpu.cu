#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <chrono>
#include <iostream>
using namespace std;

int main(){

// Carregar os dados do arquivo de entrada na memória da GPU


// Ler os dados do arquivo de entrada
int  n_cat;
int n_filmes;
int conta = 0;
int lim;
vector<int> limites;
cin >> n_filmes >> n_cat;


thrust::device_vector<int> start_times(n_filmes);
thrust::device_vector<int> end_times(n_filmes);
thrust::device_vector<int> categories(n_filmes);
thrust::device_vector<int> L(n_cat);
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


// Criar a matriz de programação dinâmica
thrust::device_vector<int> dp((n_filmes+1) * (n_cat+1), 0);

// Inicializar a primeira linha da matriz com zeros
thrust::fill(dp.begin(), dp.begin() + n_cat + 1, 0);

auto before = std::chrono::high_resolution_clock::now();

// Preencher a matriz com as soluções para subproblemas menores
for (int i = 1; i <= n_filmes; i++) {
    for (int j = 1; j <= n_cat; j++) {
        // if (L[j-1] != i) {
        //     dp[i][j] = dp[i-1][j];
        // } else {
        //     int last = i - 1;
        //     while (last >= 0 && end_times[last] > start_times[i-1]) {
        //         last--;
        //     }
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
//}

// Encontrar o número máximo de filmes que podem ser assistidos
int max_count = 0;
for (int j = 1; j <= n_cat; j++) {
  max_count = max(max_count, dp[(n_filmes*(n_cat+1)) + j]);
}


    ///// FIM DO TIMER
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

    cout << "Time: " << delta << "\n";
    cout << "N_filmes " << n_filmes << "\n";
    cout << "N_cat " << n_cat << "\n";
    cout << "TAMANHO " << max_count << "\n";
}

