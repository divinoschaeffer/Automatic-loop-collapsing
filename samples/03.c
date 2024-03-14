int main()
{
	int i;
	int j;
	int k;
	int l;
	int M;
	int N;
	int MAX_I;
	int MAX_J;
#pragma trahrhe collapse(2)
	for (i = 0; i < 30; i++)
		for (j = 2; j < N; j++)
			(void)i;
#pragma endtrahrhe
	printf("code between 2 collapse directives");
#pragma trahrhe collapse(2)
	for (i = 0; i < MAX_I; i++)
		for (j = i; j < MAX_J; j++)
			for (k = 98; k > M; k--)
				(void)i;
#pragma endtrahrhe
	return 0;
}
