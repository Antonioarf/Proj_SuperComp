#include<iostream>
#include <iterator>
#include<vector>
#include<algorithm>
#include <random>
#include <chrono>
#include <ctime>
using namespace std;

struct filme {
	int comeco, fim,cat,id;
};
bool ordena(filme f1,filme f2){
    if (f1.comeco ==f2.comeco)
    return f1.fim > f2.fim;
    else
    return f1.comeco < f2.comeco; 
}

int main(int argc, char* argv[])
{
    /////set time
    auto before = std::chrono::high_resolution_clock::now();

    vector<filme> filmes;
    vector<filme> agenda;
    vector<int> limites;
    int  n_cat;
    int n_filmes;

    cin >> n_filmes >> n_cat;

    vector<int> cats_gastas(n_cat+1, 0);
    filmes.reserve(n_filmes);
    limites.reserve(n_cat+1);
    limites.push_back(0);

    int conta = 0;
    int lim;
    int max_filmes=0;

    while(conta<n_cat){
        cin >> lim;
        limites.push_back(lim);
        conta++;
        max_filmes+=lim;

    }
    

    conta = 0;
    int com,fi,c;
    while(conta<n_filmes){
        cin >>com>>fi>>c;
        if (fi <com)
        fi+=24;
        filmes.push_back({com,fi,c,conta});
        conta++;
    }

    sort(filmes.begin(), filmes.end(), ordena);
    unsigned seed = 10;
    default_random_engine generator (seed);
    uniform_real_distribution<double> distribution(0.0,1.0);
    int hora_atual=0;
    double numero;

    for(int i=0; i < (int)filmes.size(); i++){
        numero =distribution(generator);
        if (numero >= 0.75){
            i+=(rand() % ((int)filmes.size())-i-1 );
        }
        if(filmes[i].comeco >= hora_atual){
            if (cats_gastas[filmes[i].cat]+1 <= limites[filmes[i].cat]){
                cats_gastas[filmes[i].cat]++;
                hora_atual= filmes[i].fim;
                agenda.push_back(filmes[i]);
            }

        }
    }


    ///// FIM DO TIMER
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

    cout << "Time: " << delta << "\n";
    cout << "max " << max_filmes << "\n";
    cout << "N_filmes " << n_filmes << "\n";
    cout << "N_cat " << n_cat << "\n";
    cout << "TAMANHO " << agenda.size() << "\n";

    int tempo_util = 0;
    for (auto& x : agenda){
    tempo_util += abs(x.comeco - x.fim);
    }
    cout << "TEMPO: " << tempo_util << "\n";
}