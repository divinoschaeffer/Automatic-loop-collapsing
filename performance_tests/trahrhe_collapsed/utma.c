#include "utma.h"
/* Addition de 2 matrices triangulaires */

#include <stdio.h>
#include <math.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdint.h>

#define N 11000

double a[N][N], b[N][N], c[N][N];

int main()
{
	int i, j, indic = 1;
	long int time1, time2, time3, x, y, cpt;
	struct timeval start, end;

	// init
	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
		{
			c[i][j] = (i + 1) * (j + 1) * 1.24;
			b[i][j] = (i + 1) + (j + 1) * 2.55;
		}

	// calcul
	gettimeofday(&start, NULL);
	unsigned pc_0;
	unsigned upper_bound_0 = Ehrhart0(N);
	unsigned first_iteration_0 = 1;
#pragma omp parallel for private(i, j) firstprivate(first_iteration_0) schedule(static)
	for (pc_0 = 1; pc_0 <= upper_bound_0; pc_0++)
	{
		if (first_iteration_0)
		{
			i = trahrhe_i0(pc_0, N);
			j = trahrhe_j0(pc_0, i, N);
			first_iteration_0 = 0;
		}

		a[i][j] = b[i][j] + c[i][j];

		j++;
		if (j > i - 1)
		{
			i++;
			j = 0;
		}
	}
	gettimeofday(&end, NULL);

	time1 = start.tv_sec * 1000000 + start.tv_usec;
	time2 = end.tv_sec * 1000000 + end.tv_usec;
	time3 = time2 - time1;

	printf("%ld\n", time3);

	return 0;
}
