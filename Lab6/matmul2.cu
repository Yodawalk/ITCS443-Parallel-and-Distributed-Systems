#include<stdio.h>

#define Width 32    // size of Width x Width matrix
#define TILE_WIDTH 16

__global__ void MatrixMulKernel (float* Md, float* Nd, float* Pd, int ncols) {

    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int col = blockIdx.x*blockDim.x + threadIdx.x;

    // Pvalue is used to store the element of the output matrix
    // that is computed by the thread

    float Pvalue = 0;
    for (int k = 0; k < ncols; ++k) {
        float Melement = Md[row*ncols+k];
        float Nelement = Nd[k*ncols+col];
        Pvalue += Melement * Nelement;
    }

    Pd[row*ncols+col] = Pvalue;
}

int main(int argc, char *argv[]) {

    int i,j;
    int size = Width * Width * sizeof(float);
    float M[Width][Width], N[Width][Width],P[Width][Width];
    float *Md, *Nd, *Pd;

    for(i=0;i<Width;i++) {
        for(j=0; j<Width;j++) {
            M[i][j] = 1; N[i][j]= 2;
        }
    }

    cudaMalloc( (void**)&Md, size);
    cudaMalloc( (void**)&Nd, size);
    cudaMalloc( (void**)&Pd, size);

    cudaMemcpy( Md, M, size, cudaMemcpyHostToDevice);
    cudaMemcpy( Nd, N, size, cudaMemcpyHostToDevice);

    // Setup the execution configuration
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH);
    dim3 dimGrid(Width/TILE_WIDTH,Width/TILE_WIDTH);

    // Launch the device computation threads!
    MatrixMulKernel<<<dimGrid, dimBlock>>>(Md, Nd, Pd, Width);

    // Read P from the device
    cudaMemcpy(P, Pd, size, cudaMemcpyDeviceToHost);

    // Free device matrices
    cudaFree(Md); cudaFree(Nd); cudaFree(Pd);

    for(i=0;i<Width;i++) {
        for (j=0;j<Width;j++) {
            printf("%.2f ",P[i][j]);
        }
        printf("\n");
    }
}
