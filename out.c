if (N >= 2) {
  for (i=0;i<=N-2;i++) {
    for (j=i+1;j<=N-1;j++) {
      for (k=0;k<=N-1;k++) {
        S1(i,j,k);
      }
      S2(i,j);
    }
  }
}
