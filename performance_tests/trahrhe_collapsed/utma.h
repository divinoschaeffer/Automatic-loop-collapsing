#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int N) {
 
  if ((N>=2)) {
    return (powl((long int)N,2L)-(long int)N)/2L;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (N) = (%ld)\n",N);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j,long int N) {
 
  if ((i<N) && (((0<=j) && (j<i)))) {
    return (2L*(long int)j+powl((long int)i,2L)-(long int)i+2L)/2L;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, N) = (%ld, %ld, %ld)\n",i, j,N);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int N) {
 
  if ((N>=2)) {
    return 1L;
  }
  return Ehrhart0(N);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int N) {
 
  if ((N>=2)) {
    return (powl((long int)N,2L)-(long int)N)/2L;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int N) {
 
  if ( (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int i = floorl(creall((csqrtl(8.L*(long double)pc-7.L)+1.L)/2.L)+0.00000001);
  if ((i>=1) && ((N>=i+1))) {
    return i;
  }
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, N) = (%ld,%ld)\n",pc,N);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int N) {
 
  if ( ((N>=i+1)) && (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int j = floorl(creall((2.L*(long double)pc-cpowl((long double)i,2.L)+(long double)i-2.L)/2.L)+0.00000001);
  if ((i<N) && (((0<=j) && (j<i)))) {
    return j;
  }
  }
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, i, N) = (%ld,%ld, %ld)\n",pc,i,N);
  exit(1);
} /* end trahrhe_j0 */
 
