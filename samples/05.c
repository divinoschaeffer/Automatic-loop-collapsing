int main()
{
    int i;
    int j;
    int k;
    int l;
    int **Tableau;
#pragma scop
    for (i = 0; i < 30; i++)
        for (j = i; j < 43; j++)
            for (k = 98; k > 23 || l > 9; k--)
            {
                (void)i;
                Tableau[i][j] = 0;
            }
#pragma endscop
    return 0;
}
