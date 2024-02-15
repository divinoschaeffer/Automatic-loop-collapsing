int main()
{
	int i;
	int j;
	int k;
	int l;
#pragma scop
	for (i = 0; i < 30; i++)
		for (j = i; j < 43; j++)
			for (k = 98; k > 23 || l < 3; k--)
				(void)i;
#pragma endscop
	return 0;
}
