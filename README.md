# Relatorio Parcial

# O Problema:

[https://insper.github.io/supercomp/projetos/](https://insper.github.io/supercomp/projetos/)

# O código:

Para a resolução do problema, foi primeiro desenvolvido um código generico para tratar as entradas e preparar as estruturas de dados necessarias para a resolução.

Primeiramente foram criadas as variaveis para guardar todos os filmes possiveis `filmes`,  `agenda` para guardar os filmes selecionados pelo algoritimo e `limities` e `cat_gastas`,  com quantos filmes são permitidos por categoria e quantos desses *slots* ja foram utilizados respectivamente

```cpp
vector<filme> filmes;
vector<filme> agenda;
vector<int> limites;
vector<int> cats_gastas(n_cat+1, 0);
int  n_cat;
int n_filmes;

```

Em seguida foi feita a leitura dos *inputs*, começando pleos números de categorias e de filmes, e seguido por dois *loops*, um para ler os limites de cada categoria, e um segundo para ler os dados (inicio, fim e categoria) de cada um dos filmes na lista.

```cpp
cin >> n_filmes >> n_cat;

while(conta<n_cat){
        cin >> lim;
        limites.push_back(lim);
        conta++;
        max_filmes+=lim;}  
 conta = 0;
 int com,fi,c;
 while(conta<n_filmes){
        cin >>com>>fi>>c;
        if (fi <com)
        fi+=24;
        filmes.push_back({com,fi,c,conta});
        conta++;}
```

Fechando a parte padronizada do código, o `vetor filmes`  foi ordenado a partir do horario de incio descente, e como desempate, priorizando filmes mais curtos.

```cpp
bool ordena(filme f1,filme f2){
    if (f1.comeco ==f2.comeco)
    return f1.fim < f2.fim;
    else
    return f1.comeco < f2.comeco; 
}
sort(filmes.begin(), filmes.end(), ordena);
```

A saída do programa também foi padronizada em todos os arquvios, mostrando:

 o tempo em , e os demais dados mostrados no codigo aba

- tempo
    - Medido em nanosegundos passados entre o inicio da função `main` e o fim do *loop* principal
- Max_filmes
    - Número maximo de filmes possiveis pelo limite das categorias somados
- N_filmes
    - Número N de filmes presentes no *input*
- N_cat
    - Número M de categorias presentes no *input*
- Tamanho
    - Quantidade de filmes selecionados pela heurística
- Tempo_util
    - horas de tela disponivel entre os filmes selecionados

```cpp
auto after = chrono::high_resolution_clock::now();
auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();
cout << "Time: " << delta << "\n";
cout << "max " << max_filmes << "\n";
cout << "N_filmes " << n_filmes << "\n";
cout << "N_cat " << n_cat << "\n";
cout << "TAMANHO " << agenda.size() << "\n";

int tempo_util = 0;
for (auto& x : agenda)
	tempo_util += abs(x.comeco - x.fim);
cout << "TEMPO: " << tempo_util << "\n";

```

# As heurísticas:

## Heurística Gulosa:

Uma vez com a lista de filmes devidamente ordenada foi implementado o *loop* principal, que varre todo o vertor de filmes, verificando para cada um se o horario de começo dele ainda não esta ocupado (variavel `hora_atual`) e caso esteja disponivel, faz a validação pela categoria.

Caso ambos os testes sejam vedadeiros, os *slots* da categoria e a hora atual são atualizados, e o filme é adicionado na agenda.

```cpp
int hora_atual=0;
for (auto& x : filmes){
    if(x.comeco >= hora_atual){
        if (cats_gastas[x.cat]+1 <= limites[x.cat]){
            cats_gastas[x.cat]++;
            hora_atual= x.fim;
            agenda.push_back(x);
        }}}
```

### Gulosa invertida:

Foi tambêm criado o arquivo `gulosa_invertida.cpp` no gual durante a ordenação da lista, ao invez serem prioridados filmes mais curtos, passam a ser priorizados filmes mais longos, dado mesmo horario de inicio.

## Aleatorização

A segunda heurística implementada foi a adição de mutações à heurística gulosa, para isso foi criada uma *engine* de numeros pseudo-aleatorios com *seed* constante para padronização dos testes, segindo uma destribuição linear entre 0 e 1.

```cpp
unsigned seed = 10;
default_random_engine generator (seed);
uniform_real_distribution<double> distribution(0.0,1.0);
int hora_atual=0;
double numero;
```

Para o algoritimo ter mais maleabilidade para percorrer o vetor, o *loop for* deixou de iterar sobre itens no vetor, como era na heurística gulosa, e passou a varrer indicies de 0 até a quantidade de filmes menos um.

O *loop* principal tambêm foi alterado para gerar um `numero` aleatorio, com 25% de chance de disparar uma mutação, descrita no primeiro *if*, que consiste em um salto para qualquer filme ainda não contemplado no vetor de filmes 

```cpp
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
```