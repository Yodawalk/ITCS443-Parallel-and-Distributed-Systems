#include<stdio.h>

#define Width 32    // size of Width x Width matrix
#define TILE_WIDTH 16

__global__ void matrixMul(float* A, float* B, float* C, int width)
{
    __shared__ float As[TILE_WIDTH] [TILE_WIDTH];
    __shared__ float Bs[TILE_WIDTH] [TILE_WIDTH];
    int row = blockIdx.y * TILE_WIDTH + threadIdx.y;
    int col = blockIdx.x * TILE_WIDTH + threadIdx.x;
    float c_val = 0.0f;for(int i = 0; i < width/TILE_WIDTH; i++)
    {
        As[threadIdx.y][threadIdx.x] = A[row * width + (i * TILE_WIDTH + threadIdx.x)];
        Bs[threadIdx.y][threadIdx.x] = B[(i * TILE_WIDTH + threadIdx.y) * width + col ];
        __syncthreads();
        for(int k = 0; k < TILE_WIDTH; k++)
        c_val += As[threadIdx.y][k] * Bs[k][threadIdx.x];__syncthreads();
    }
    C[row * width + col] = c_val;
}

int main (int argc, char *argv[] ) {
    const int n = 16;
    int i,j;
    int size = Width * Width * sizeof(float);
    float M[Width][Width],N[Width][Width],P[Width][Width];
    float *Md, *Nd, *Pd;

    for (i=0; i < Width; i++) {
        for (j=0; j < Width; j++) {
            M[i][j] = 1; N[i][j] = 2;
        }
    }

    cudaMalloc( (void**)&Md, size);
    cudaMalloc( (void**)&Nd, size);
    cudaMalloc( (void**)&Pd, size);

    cudaMemcpy( Md, M, size, cudaMemcpyHostToDevice);
    cudaMemcpy( Nd, N, size, cudaMemcpyHostToDevice);

    // Setup the execution configuration
    dim3 dimBlock(n, n);
    dim3 dimGrid(Width/n, Width/n);

    // Launch the device computation threads!
    matrixMul<<<dimGrid, dimBlock>>>(Md, Nd, Pd, Width);

    // Read P from the device
    cudaMemcpy(P, Pd, size, cudaMemcpyDeviceToHost);

    // Free device matrices
    cudaFree(Md); cudaFree(Nd); cudaFree(Pd);

    for (i=0; i < Width; i++) {
        for (j=0; j< Width; j++) {
            printf("%.2f ",P[i][j]);
        }
        printf("\n");
    }
}
