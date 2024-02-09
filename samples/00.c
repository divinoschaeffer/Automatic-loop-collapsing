int main() {
	int i;
	int j;
	int k;
	int l;
	int *P, *A, *B;
	#pragma scop	
	for (i = 2; i <= 4; i++)
		for (j = 2; j <= 4; j++)
			P[i+j] += A[i] + B[j]; // S4
	#pragma endscop
	return 0;
}
