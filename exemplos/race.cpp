#include<iostream>
#include<vector>
#include<algorithm>
#include <random>
#include <chrono>
#include <ctime>
#include <omp.h>
#include <bitset>
using namespace std;

// g++ -Wall -O3 arquivo.cpp -o executavel
// g++ -Wall -fopenmp -O3 exaustiva.cpp -o exal
struct filme {
	int comeco, fim,cat,id;
};
struct result {
    int quant, horas;
};

result maximo(result r1, result r2){
    if (r1.quant >= r2.quant) {return r1;}
    // if (r1.horas >= r2.horas) {return r1;}
    else {return r2;}
}
bool ordena(filme f1,filme f2){ //invertendo pra facilitar o criterio de parada
    if (f1.fim ==f2.fim)
    return f1.comeco > f2.comeco;
    else
    return f1.fim > f2.fim; 
}
int knapSack(bitset<32> &agenda, int indicie, vector<bitset<32>> &horarios ){
    if (indicie <= 0 || agenda.count() >=24) {
        // cout << "agenda " << agenda << "\n";
        return 0;
    }
    if ((horarios[indicie] & agenda).any()) {
        // cout << "meio" << "\n";
        return knapSack(agenda, indicie-1, horarios);
    }
    else {
        bitset<32> nova = agenda | horarios[indicie];
        int r1 = knapSack(nova, indicie-1, horarios) +1;
        int r2 = knapSack(nova2, indicie-1, horarios);
        return max(r1,r2);
    }

}

int main(int argc, char* argv[])
{
        auto before = std::chrono::high_resolution_clock::now();

    
    int  n_cat;
    int n_filmes;

    cin >> n_filmes >> n_cat;

    vector<int> limites;
    limites.reserve(n_cat);
    vector<bitset<32>> horarios(n_filmes);
    vector<int> cats(n_filmes);

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

        for (int i = com; i < fi; i++)
        {
            horarios[conta].set(i); 
        }
        cats[conta] = c-1;
        conta++;
    }

    bitset<32> agenda(0);
    cout << "agenda " << agenda << "\n";
    int resultado = knapSack(agenda, n_filmes-1, horarios);


    ///// FIM DO TIMER
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

    cout << "Time: " << delta << "\n";
    cout << "max " << max_filmes << "\n";
    cout << "N_filmes " << n_filmes << "\n";
    cout << "N_cat " << n_cat << "\n";
    cout << "TAMANHO " << resultado << "\n";

}
