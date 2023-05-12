#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <iostream>
using namespace std;

int main(){
    thrust::host_vector<int> host(5,0); // 5 elements with value 0
    host[4]=35;
    thrust::device_vector<int> dev(host); //copia host para dev (cpu para gpu)

    for(int i=0;i<5;i++){ //proibido for na GPU,só na CPU
        cout<<host[i]<<" \n";
    }

    for (auto i = dev.begin(); i != dev.end(); ++i) { //eh oq n deve ser feito
        cout<<*i<<" \n";
    }
    //gets index of highest value
    int val = thrust::reduce(dev.begin(), dev.end(), 0, thrust::maximum<int>());
    cout<<"val: "<<val<<endl;
    return 0;
}
