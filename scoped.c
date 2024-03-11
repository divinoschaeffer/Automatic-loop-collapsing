int i, j, k, *A, *B, *C;
#pragma scop
for (i = 0; i < N - 1; i++)
{
    for (j = i + 1; j < N; j++)
    {
        for (k = 0; k < N; k++)
        {
            A[i][j] += B[k][i] * C[k][j];
        }
        A[j][i] = A[i][j];
    }
}
#pragma endscop
