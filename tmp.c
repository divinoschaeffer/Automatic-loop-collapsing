for (j=i+1;j<=N-1;j++) {
  for (k=0;k<=N-1;k++) {
    A[i][j] += B[k][i] * C[k][j];
  }
  A[j][i] = A[i][j];
}
