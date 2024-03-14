#include "intermediate.source.h"
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

		(void)(i);

		j++;
		if (j < N - 1)
		{
			i++;
			j = i + 1;
		}
	}

	printf("code between 2 collapse directives");

	unsigned pc_1;
	unsigned upper_bound_1 = Ehrhart1(MAX_I, MAX_J, M);
	unsigned first_iteration_1 = 1;
#pragma omp parallel for private(i, j, k) firstprivate(first_iteration_1) schedule(static)
	for (pc_1 = 1; pc_1 <= upper_bound_1; pc_1++)
	{
		if (first_iteration_1)
		{
			i = trahrhe_i1(pc_1, MAX_I, MAX_J, M);
			j = trahrhe_j1(pc_1, i, MAX_I, MAX_J, M);
			first_iteration_1 = 0;
		}

		for (k = -98; k <= -M - 1; k++)
		{
			(void)(i);
		}

		j++;
		if (j < MAX_J - 1)
		{
			i++;
			j = i + 1;
		}
	}

	return 0;
}
