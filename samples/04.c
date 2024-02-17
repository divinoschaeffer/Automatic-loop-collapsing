int main()
{
	int i;
	int j;
	int k;
	int l;
#pragma scop
	for (i = 0; i < N - 1; i++)
	{
		for (j = i + 1; j < N; j++)
		{
			(void)i;
		}
	}
#pragma endscop
	return 0;
}
