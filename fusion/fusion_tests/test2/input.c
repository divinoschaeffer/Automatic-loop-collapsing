#include <stdio.h>

#define N 1000

int i, j, k;
double A[N][N], B[N][N], C[N][N];

#pragma scop
for(i = 0; i < N - 1; i++) {
    for(j = i + 1; j < N; j++) {
        for(k = 0; k < N; k++) {
            A[i][j] += B[k][i] * C[k][j];
        }
        A[j][i] = A[i][j];
    }
}
#pragma endscop

int bonjour = 0;

#pragma scop
for(i = 0; i < N - 1; i++) {
    for(j = i + 1; j < N; j++) {
        for(k = 0; k < N; k++) {
            A[i][j] += B[k][i] * C[k][j];
        }
        A[j][i] = A[i][j];
    }
}
#pragma endscop