#include <stdio.h>

#define N 100

void main()
{
    int i, j, k;
    int A[N][N], B[N][N], C[N][N];
    for (i = 0; i < N; i++)
    {
        for (j = 0; j < N; j++)
        {
            A[i][j] = 0;
            B[i][j] = i + j;
            C[i][j] = i - j;
        }
    }
#pragma trahrhe collapse(2)
    for (i = 0; i < N - 1; i++)
    {
        for (j = i + 1; j < N; j++)
        {
            for (k = 0; k < N; k++)
            {
                A[i][j] += B[k][i] * C[k][j];
            }
            A[j][i] = A[i][j];
            printf("A[%d][%d] = %d\n", i, j, A[i][j]);
        }
    }
#pragma endtrahrhe
}
