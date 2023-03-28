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
int avalia(vector<filme> *lista,filme f2){
    if ((*lista).empty()){
        return 1;
    }
    for (filme& f1 : *lista) {
    if (f2.comeco >= f1.comeco){
        if (f2.fim <= f1.fim){
            return true;
        }
        
    else if (f2.comeco >=f1.fim)
        return false;
    } 
    
}
return false;
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

    //COMECA  A HEURISTICA PROPRIAMENTE
    //sort(filmes.begin(), filmes.end(), ordena);

    random_shuffle(filmes.begin(), filmes.end());
    cout << "max " << max_filmes << "\n";

    //int hora_atual=0;
    int index;
    //cout << "VAZIO: " << (agenda.size() == 0 ) << "\n";

    for (filme& x : filmes){
        index = avalia(&agenda,x);
        if(index >0){
            if (cats_gastas[x.cat]+1 <= limites[x.cat]){
                cats_gastas[x.cat]++;
                //hora_atual= x.fim;
                agenda.insert(agenda.begin() + index, x); // agenda.push_back(x);  
            }

        }
    }
    ///// FIM DO TIMER
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();
    
    //----------------------------------------------------//
    ///// Output
    cout << "Time: " << delta << "\n";
    cout << "max " << max_filmes << "\n";
    cout << "N_filmes " << n_filmes << "\n";
    cout << "N_cat" << n_cat << "\n";
    cout << "MAXIMO " << max_filmes << "\n";
    cout << "TAMANHO " << agenda.size() << "\n";

    //conta = 0;
    //while (conta< n_cat+1)
    //{cout << "Cat " << conta << " limite "<< limites[conta]<< " usados "<< cats_gastas[conta]<< "\n";
    //conta++;}

    // for (auto& x : filmes)cout << nums.size();
    // cout <<"ID " << x.id <<" Comeco " << x.comeco << ", fim:" << x.fim << " ,Cat: "<< x.cat <<"\n";
    //cout<< "---------------------\n";
    int tempo_util = 0;
    for (auto& x : agenda){
    // cout <<"ID " << x.id <<" Comeco " << x.comeco << ", fim:" << x.fim << " ,Cat: "<< x.cat <<"\n";
    tempo_util += abs(x.comeco - x.fim);
    }
    cout << "TEMPO: " << tempo_util << "\n";
}