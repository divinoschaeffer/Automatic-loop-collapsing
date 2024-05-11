/* Produit de 2 matrices triangulaires 3D */

#include <stdio.h>
#include <math.h>
#include <sys/time.h>
#include <stdlib.h>

#define N 2000

double a[N + 1][N + 1][N + 1], b[N + 1][N + 1], c[N + 1][N + 1];

int main()
{
	int i, j, k, tmpi;
	long int time1, time2, time3, x, y, pc, pc1, pc2;
	struct timeval start, end;
	double tmp1, tmp2, tmp3, tmp21, tmp31;
	int indic = 1;

	// init
	for (i = 0; i < N + 1; i++)
		for (j = 0; j < N + 1; j++)
		{
			b[i][j] = (i + 1) * (j + 1) * 1.24;
			c[i][j] = (i + 1) + (j + 1) * 2.55;
		}

	// calcul
	gettimeofday(&start, NULL);
#pragma omp parallel for private(j, k) schedule(static)
	for (i = 0; i < N + 1; i++)
		for (j = 0; j < i + 1; j++)
			for (k = 0; k < i - j + 1; k++)
				a[i][j][k + j] = b[i][k + j] * c[k + j][j];
	gettimeofday(&end, NULL);

	time1 = start.tv_sec * 1000000 + start.tv_usec;
	time2 = end.tv_sec * 1000000 + end.tv_usec;
	time3 = time2 - time1;

	printf("%ld\n", time3);

	return 0;
}
