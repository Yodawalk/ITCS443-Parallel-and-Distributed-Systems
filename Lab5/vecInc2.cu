#include <stdio.h>


#define N 1000

__global__ void vecAdd(int *A) {
	int i = threadIdx.x;
	A[i]=A[i]+1;
}

int main (int argc, char *argv[]){
	int i;
	int size = N*sizeof(int);
	int a[N],*devA;

	for (i=0; i< N; i++){
		a[i] = i;
	}
	cudaMalloc( (void**)&devA,size);

	cudaMemcpy( devA, a, size, cudaMemcpyHostToDevice);

	vecAdd<<<1, 256>>>(devA);

	cudaMemcpy(a, devA, size, cudaMemcpyDeviceToHost);
	cudaFree(devA);

	for (i=0; i < N; i++) {
		printf("%d ",a[i]);
	}
	printf("\n");

}
