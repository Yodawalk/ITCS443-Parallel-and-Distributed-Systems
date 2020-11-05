#include <stdio.h>
#define Width 31

#define TITE_WIDTH 16

__global__ void MatrixMulKernel (float* Md, float* Nd, float* Pd, int ncols) {
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	printf("Block ID X : %d and  Block ID Y: %d\n", blockIdx.x,blockIdx.y);
	float Pvalue = 0;
	if(row < Width || col < Width){
	for(int k=0;k<ncols;k++){
		float Melement = Md[row*ncols+k];
		float Nelement = Nd[k*ncols+col];
		Pvalue += Melement * Nelement;
	}
}
	
	Pd[row*ncols+col] = Pvalue;
}

int main (int argc, char *argv[]){
	int i,j;
	int size = Width * Width * sizeof(float);
	float M[Width][Width], N[Width][Width], P[Width][Width];
	float* Md, *Nd, *Pd;
	
	for(i=0;i<Width;i++){
		for(j=0;j<Width;j++){
			M[i][j] = 1;
			N[i][j] = 2;
		}
	}
	cudaMalloc( (void**)&Md, size);
	cudaMalloc( (void**)&Nd, size);
	cudaMalloc( (void**)&Pd, size);
	
	cudaMemcpy( Md, M, size, cudaMemcpyHostToDevice);
	cudaMemcpy( Nd, N, size, cudaMemcpyHostToDevice);
	
	dim3 dimBlock(TITE_WIDTH, TITE_WIDTH);
	dim3 dimGrid((Width+TITE_WIDTH-1)/TITE_WIDTH,(Width+TITE_WIDTH-1)/TITE_WIDTH);
	
	MatrixMulKernel<<<dimGrid, dimBlock>>>(Md, Nd, Pd, Width);
	
	cudaMemcpy(P, Pd, size, cudaMemcpyDeviceToHost);
	
	cudaFree(Md);
	cudaFree(Nd);
	cudaFree(Pd);
	printf("\n================================\n");
	for(i=0;i<Width;i++){
		for(j=0;j<Width;j++){
			printf("%.2f ", P[i][j]);
		}
	}
}
