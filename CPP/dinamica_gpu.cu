%%writefile dinamica2.cu
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sequence.h>
#include <thrust/transform.h>
#include <thrust/fill.h>
#include <thrust/functional.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/transform_reduce.h>

#include <chrono>
#include <iostream>

using namespace std;

struct UpdateFunctor
{
    int* categories;
    int* end_times;
    int* start_times;
    int* dp;
    int* L;
    int M;

    __host__ __device__
    UpdateFunctor(int* _categories, int* _end_times, int* _start_times, int* _dp, int* _L, int _M)
        : categories(_categories), end_times(_end_times), start_times(_start_times), dp(_dp), L(_L), M(_M)
    {
    }

    __host__ __device__
    int operator()(int i) const
    {
        int max_count = 0;
        int j = threadIdx.x + blockIdx.x * blockDim.x;

        for (int k = 0; k < i; k++)
        {
            if (categories[k] == j && end_times[k] <= start_times[i] && dp[(k * (M + 1)) + j - 1] + 1 <= L[j - 1])
            {
                max_count = max(max_count, dp[(k * (M + 1)) + j - 1] + 1);
            }
            else
            {
                max_count = max(max_count, dp[(k * (M + 1)) + j]);
            }
        }

        dp[(i * (M + 1)) + j] = max_count;
        return max_count;
    }
};
int main()
{
  auto before = std::chrono::high_resolution_clock::now();

    int N; // Number of elements in categories and end_times
    int M;  // Number of columns in dp array
    
    std::cin >> N >> M;

    // Input data
    int categories[N] ;
    int end_times[N] ;
    int start_times[N] ;
    int dp[(N + 1) * (M + 1)];
    int L[M];

    int  conta = 0;
    int  lim   =0;
    while(conta<M){
            std::cin >> lim;
            L[conta] = lim;
            conta++;
        }

    conta = 0;
    int i1, i2, i3;
    while(conta<N){
            std::cin >> i1 >> i2 >> i3;
            start_times[conta] = i1;
            end_times[conta] = i2;
            categories[conta] = i3;
            conta++;
        }

    for (int i =0;i<N;i++){
        cout << categories[i] << " " << end_times[i] << " " << start_times[i] << endl;
    }

    // Transfer input data to device
    thrust::device_vector<int> d_categories(categories, categories + N);
    thrust::device_vector<int> d_end_times(end_times, end_times + N);
    thrust::device_vector<int> d_start_times(start_times, start_times + N);
    thrust::device_vector<int> d_dp(dp, dp + (N + 1) * (M + 1));
    thrust::device_vector<int> d_L(L, L + M);


    thrust::fill(d_dp.begin(), d_dp.begin() + M + 1, 1);
    
    int numElements = ((N + 1) * (M + 1));
    thrust::counting_iterator<int> first(10);
    thrust::counting_iterator<int> last = first + numElements;

    // // Launch the kernel and update the dp array
     UpdateFunctor functor(thrust::raw_pointer_cast(d_categories.data()),
                           thrust::raw_pointer_cast(d_end_times.data()),
                           thrust::raw_pointer_cast(d_start_times.data()),
                           thrust::raw_pointer_cast(d_dp.data()),
                           thrust::raw_pointer_cast(d_L.data()),
                           M);

     thrust::transform(thrust::counting_iterator<int>(0), thrust::counting_iterator<int>(numElements),
                       d_dp.begin(), functor);

    // Transfer result back to host
    thrust::copy(d_dp.begin(), d_dp.end(), dp);

    // Print the updated dp array
    int max_count = 0;
    for (int j = 1; j <= M; j++) {
      max_count = max(max_count, dp[(N*(M+1)) + j]);
      //std::cout<< ((N*(M+1)) + j)<< std::endl;
    }
    auto after = chrono::high_resolution_clock::now();
    auto delta = chrono::duration_cast<chrono::nanoseconds>(after-before).count();
    std::cout << delta<< " , " << N<< " , " << M<< " , "<< max_count << "\n";
    return 0;
}
