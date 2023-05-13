#include<iostream>
#include<vector>
#include<algorithm>
#include <random>
#include <chrono>
#include <ctime>
#include <omp.h>
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

result knapSack(int horario, vector<int>& lim, vector <filme>& filmes){
    if (filmes.empty() || horario==0) return result ({0,0}); //nao tem nada pra colocar

    if (filmes[0].fim>horario || lim[filmes[0].cat]== 0 ){ //nao cabe ou por categoria ou por horario
        filmes.erase(filmes.begin());
        return knapSack(horario,lim, filmes);
    }
    
    else{
        filme f0 = filmes[0];
        filmes.erase(filmes.begin());
        vector<int> lim0 = lim;
        lim0[filmes[0].cat]-=1;

        result rec, rec2;
        rec = knapSack(f0.comeco,lim0, filmes);
        rec.horas += (f0.fim - f0.comeco);
        rec.quant +=1; 
        rec2 = knapSack(horario,lim, filmes);
        return maximo(rec, rec2);
    }
}

int main(int argc, char* argv[])
{
    /////set time
    auto before = std::chrono::high_resolution_clock::now();

    vector<filme> filmes;
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
    result resultado = knapSack(10000,limites ,filmes);


    ///// FIM DO TIMER
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();

    cout << "Time: " << delta << "\n";
    cout << "max " << max_filmes << "\n";
    cout << "N_filmes " << n_filmes << "\n";
    cout << "N_cat " << n_cat << "\n";
    cout << "TAMANHO " << resultado.quant << "\n";
    cout << "TEMPO: " << resultado.horas << "\n";
}


