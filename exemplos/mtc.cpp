#include <iostream>
#include <omp.h>
#include <unistd.h>
#include <random>
using namespace std;

int main()
{
    int N  = 5000000;
    int count = 0;
    #pragma omp parallel
    {
        // cd Declare a seed for each thread
        unsigned my_seed = omp_get_thread_num() + time(NULL);
        cout <<"SEED" << omp_get_thread_num << my_seed;
        // Create a random number generator for each thread
        default_random_engine generator(my_seed);

        // Define a distribution for the generator
        uniform_real_distribution<double> distribution(0.0,1.0);

        // Count the number of points inside the circle for each thread
        #pragma omp for reduction(+:count)
        for (int i = 0; i < N; i++){
            float x = .(generator); 
            float y = distribution(generator);
            if (x*x + y*y <= 1.0){count++;}
        }
    }

    cout << "Pi = " << 4.0*count/N  << endl;

    return 0;
}
