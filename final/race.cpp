#include <iostream>
#include <omp.h>
#include<unistd.h>
using namespace std;
// rever: nowait, privet, critical, grupos de Sections
int main()
{
    int a  =0;
    #pragma omp parallel
    {
        #pragma omp critical
        {
            cout << "Thread " << omp_get_thread_num() << endl;
            a = a + omp_get_thread_num();}
    }
    cout << "a = " << a << endl;
    return 0;
}