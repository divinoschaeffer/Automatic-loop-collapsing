int main()
{
	int i;
	int j;
	int k;
	int l;
	int M = 20;
	int N = 30;
	int MAX_I = 30;
	int MAX_J = 30;
#pragma trahrhe collapse(2)
	for (i = 0; i < 30; i++)
		for (j = 2; j < N; j++)
			(void)i;
#pragma endtrahrhe
	printf("code between 2 collapse directives");
#pragma trahrhe collapse(3)
	for (i = 0; i < MAX_I; i++)
		for (j = i; j < MAX_J; j++)
			for (k = 98; k > M; k--)
			{
				(void)i;
				A[i][j][k] = B[i][j][k];
			}
#pragma endtrahrhe
	return 0;
}
