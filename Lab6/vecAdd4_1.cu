#include <stdio.h>

#define T 64
#define n 256

__global__ void vecAdd(int *A, int *B, int *C) {
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	C[i] = A[i];
}

int main (int argc, char *argv[]){
	int i;
	int size = n*sizeof(int);
	int a[n], b[n], c[n], *devA, *devB, *devC;

	for (i=0; i< n; i++){
		a[i] = i;	}
	cudaMalloc( (void**)&devA,size);
	cudaMalloc( (void**)&devB,size);
	cudaMalloc( (void**)&devC,size);

	cudaMemcpy( devA, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy( devB, b, size, cudaMemcpyHostToDevice);

	
	vecAdd<<<n/T, T>>>(devA, devB, devC);

	cudaMemcpy(c, devC, size, cudaMemcpyDeviceToHost);
	cudaFree(devA);
	cudaFree(devB);
	cudaFree(devC);

	for (i=0; i < n; i++) {
		printf("%d ",c[i]);
	}
	printf("\n");

}
