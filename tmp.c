for (k=0;k<=N-1;k++) {
  A[i][j] += B[k][i] * C[k][j];
}
A[j][i] = A[i][j];
