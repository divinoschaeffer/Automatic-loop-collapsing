#include "new.h"

//start//
unsigned pc_0;
unsigned upper_bound_0 = Ehrhart0(N);
unsigned first_iteration_0 = 1;
#pragma omp parallel for private(i, j, k) firstprivate(first_iteration_0) schedule(static)
for (pc_0 = 1; pc_0 <= upper_bound_0; pc_0++)
{
    if (first_iteration_0)
    {
        i = trahrhe_i0(pc_0, N);
        j = trahrhe_j0(pc_0, i, N);
        first_iteration_0 = 0;
    }

    for (k = 0; k <= N - 1; k++)
    {
        A[i][j] += B[k][i] * C[k][j];
    }
    A[j][i] = A[i][j];

    j++;
    if (j < N - 1)
    {
        i++;
        j = i + 1;
    }
}
//end//

//start//
unsigned pc_0;
unsigned upper_bound_0 = Ehrhart0(N);
unsigned first_iteration_0 = 1;
#pragma omp parallel for private(i, j, k) firstprivate(first_iteration_0) schedule(static)
for (pc_0 = 1; pc_0 <= upper_bound_0; pc_0++)
{
    if (first_iteration_0)
    {
        i = trahrhe_i0(pc_0, N);
        j = trahrhe_j0(pc_0, i, N);
        first_iteration_0 = 0;
    }

    for (k = 0; k <= N - 1; k++)
    {
        A[i][j] += B[k][i] * C[k][j];
    }
    A[j][i] = A[i][j];

    j++;
    if (j < N - 1)
    {
        i++;
        j = i + 1;
    }
}
//end//