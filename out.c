unsigned pc;
unsigned upperBound = i_Ehrhart(P1);
unsigned first_iteration = 1;
#pragma omp for private(i,j) firstprivate(first_iteration) schedule(static)
for (pc = 1; pc <= upperBound; pc++)
{
	if (first_iteration)
	{
		first_iteration = 0;
	}
	
	for (i=0;i<=29;i++) {
	  for (j=2;j<=42;j++) {
	    S1(i,j);
	  }
	}
unsigned pc;
unsigned upperBound = i_Ehrhart(l);
unsigned first_iteration = 1;
#pragma omp for private(i,j,k) firstprivate(first_iteration) schedule(static)
for (pc = 1; pc <= upperBound; pc++)
{
	if (first_iteration)
	{
		first_iteration = 0;
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
