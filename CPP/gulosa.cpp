#include<iostream>
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
    return f1.fim < f2.fim;
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
    int hora_atual=0;
    for (auto& x : filmes){
        if(x.comeco >= hora_atual){
            if (cats_gastas[x.cat]+1 <= limites[x.cat]){
                cats_gastas[x.cat]++;
                hora_atual= x.fim;
                agenda.push_back(x);
            }

        }
    }


    ///// FIM DO TIMER
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

    int tempo_util = 0;
    for (auto& x : agenda){
    tempo_util += abs(x.comeco - x.fim);
    }
    cout << delta<< " , " << n_filmes<< " , " << n_cat<< " , "<< agenda.size() << " , "<< tempo_util<< "\n";
}