E[i][j] = SCALAR_VAL(0.0);
for (k=0;k<=_PB_NK-1;k++) {
  E[i][j] += A[i][k] * B[k][j];
}
