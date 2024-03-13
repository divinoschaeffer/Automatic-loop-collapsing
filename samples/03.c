int main()
{
	int i;
	int j;
	int k;
	int l;
	int M;
	int N;
#pragma trahrhe collapse(2)
	for (i = 0; i < 30; i++)
		for (j = 2; j < N; j++)
			(void)i;
#pragma endtrahrhe
#pragma trahrhe collapse(2)
	for (i = 0; i < 30; i++)
		for (j = i; j < 43; j++)
			for (k = 98; k > M; k--)
				(void)i;
#pragma endtrahrhe
	return 0;
}
