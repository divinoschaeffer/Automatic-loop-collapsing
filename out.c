unsigned pc_0;
unsigned upper_bound_0 = i_Ehrhart0(l);
unsigned first_iteration_0 = 1;
#pragma omp parallel for private(i,j,k) firstprivate(first_iteration_0) schedule(static)
for (pc_0 = 1; pc_0 <= upper_bound_0; pc_0++)
{
	if (first_iteration_0)
	{
		first_iteration_0 = 0;
	}
	
	(void)(i);
	Tableau[i][j] = 0;
}

