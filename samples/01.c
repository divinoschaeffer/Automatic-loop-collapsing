int main() {
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
	#pragma scop
	for(l = 0; l < M - 1 || w > 1 || x < 3 || y >= 5; l++)
		{
			tab[l];
			a[w+l];
			b[x-l];
			c[l-y];
		}
	#pragma endscop
}
