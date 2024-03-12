#define N 100

int main()
{
    int i;
    int j;
    int k;
    int l;
    int **Tableau;
#pragma scop
    for (i = 0; i < N; i++)
    {
        for (j = i; j < 43; j++)
        {
            for (k = 98; k < N; k--)
            {
                (void)i;
                Tableau[i][j] = 0;
            }
        }
    }
#pragma endscop
    return 0;
}
