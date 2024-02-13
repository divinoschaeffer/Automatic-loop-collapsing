unsigned pc;
unsigned upperBound = i_Ehrhart(l);
unsigned first_iteration = 1;
#pragma omp for private(i,j,k) firstprivate(first_iteration) schedule(static)
for (pc = 1; pc < upperBound; pc++)
{
	if (first_iteration)
	{
		first_iteration = 0;
	}
	
	for (i=0;i<=29;i++) {
	  for (j=i;j<=42;j++) {
	    for (k=-98;k<=-24;k++) {
	      S1(i,j,-k);
	    }
	    if (l <= 2) {
	      for (k=-23;;k++) {
	        S1(i,j,-k);
	      }
	    }
	  }
	}
}
