#include <stdio.h>

#define T 1024
#define n 240

__global__ void vecAdd(int *A, int *B, int *C) {
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	if(i<n)C[i] = A[i] + B[i];
}

int main (int argc, char *argv[]){
	int i;
	int size = n*sizeof(int);
	int a[n], b[n], c[n], *devA, *devB, *devC;

	for (i=0; i< n; i++){
		a[i] = 1; b[i] =2;
	}
	cudaMalloc( (void**)&devA,size);
	cudaMalloc( (void**)&devB,size);
	cudaMalloc( (void**)&devC,size);

	cudaMemcpy( devA, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy( devB, b, size, cudaMemcpyHostToDevice);

	int blocks = (n + T - 1) /T;
	vecAdd<<<blocks, T>>>(devA, devB, devC);

	cudaMemcpy(c, devC, size, cudaMemcpyDeviceToHost);
	cudaFree(devA);
	cudaFree(devB);
	cudaFree(devC);

	for (i=0; i < n; i++) {
		printf("%d ",c[i]);
	}
	printf("\n");

}
