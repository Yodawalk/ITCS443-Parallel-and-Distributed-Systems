#include <stdio.h>

#define n 1024
#define NUMTHREADS 256

__global__ void histogram_kernel( unsigned int *data, unsigned int *bin) {
int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n) 
  {
    atomicAdd( &(bin[data[i]]), 1 );
  }
}

int main (int argc, char *argv[] ) {
int i;
int size = n *sizeof(int);
unsigned int a[n];     
unsigned int bin[10];
unsigned int *dA, *dBin;
  for (i=0; i < n; i++) 
    {
      a[i] = i % 10;
    }

cudaMalloc( (void**)&dA, size);
cudaMalloc( (void**)&dBin, 10*sizeof(int));
cudaMemcpy( dA, a, size, cudaMemcpyHostToDevice);
cudaMemset( dBin,0, 10*sizeof(int));

int nblocks = (n+NUMTHREADS-1)/NUMTHREADS;
histogram_kernel<<<nblocks, NUMTHREADS>>>(dA,dBin); 
cudaMemcpy(bin, dBin, 10*sizeof(int), cudaMemcpyDeviceToHost);
  
cudaFree( dA);
cudaFree( dBin);
  
int count = 0;
    for (i=0; i < 10; i++) 
      {
        printf("Freq %d = %d\n",i,bin[i]);
        count = count + bin[i];
      }
   printf("#elements = %d\n",count);
}
