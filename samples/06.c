int i, j, k, *A, *B, *C;
#pragma scop
for (i = 0; i < N; i++)
{
    for (j = i + 1; j < O; j++)
    {
        for (k = 0; k < r; k++)
        {
            A[i][j] += B[k][i] * C[k][j];
        }
        A[j][i] = A[i][j];
    }
}
#pragma endscop