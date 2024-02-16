unsigned pc_0;
unsigned upper_bound_0 = i_Ehrhart0(P1);
unsigned first_iteration_0 = 1;
#pragma omp for private(i,j) firstprivate(first_iteration_0) schedule(static)
for (pc = 1; pc <= upper_bound; pc++)
{
	if (first_iteration_0)
	{
		first_iteration_0 = 0;
	}
	
	for (i=0;i<=29;i++) {
	  for (j=2;j<=42;j++) {
	    S1(i,j);
	  }
	}
}

unsigned pc_1;
unsigned upper_bound_1 = i_Ehrhart1(l);
unsigned first_iteration_1 = 1;
#pragma omp for private(i,j,k) firstprivate(first_iteration_1) schedule(static)
for (pc = 1; pc <= upper_bound; pc++)
{
	if (first_iteration_1)
	{
		first_iteration_1 = 0;
	}
	
	for (i=0;i<=29;i++) {
	  for (j=i;j<=42;j++) {
	    if (l >= 10) {
	      for (k=-98;;k++) {
	        S1(i,j,-k);
	      }
	    }
	    if (l <= 9) {
	      for (k=-98;k<=-24;k++) {
	        S1(i,j,-k);
	      }
	    }
	  }
	}
}

