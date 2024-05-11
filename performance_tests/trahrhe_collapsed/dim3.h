#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int N) {
 
  if ((N>=0)) {
    return ((long int)N*((long int)N*((long int)N+6L)+11L)+6L)/6L;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (N) = (%ld)\n",N);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j, long int k,long int N) {
 
  if ((i<=N) && ((j>=0)) && (((0<=k) && (k<=i-j)))) {
    return (6L*(long int)k-3L*powl((long int)j,2L)+6L*(long int)i*(long int)j+9L*(long int)j+powl((long int)i,3L)+3L*powl((long int)i,2L)+2L*(long int)i+6L)/6L;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, k, N) = (%ld, %ld, %ld, %ld)\n",i, j, k,N);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int N) {
 
  if ((N>=0)) {
    return 1L;
  }
  return Ehrhart0(N);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int N) {
 
  if ((N>=0)) {
    return ((long int)N*((long int)N*((long int)N+6L)+11L)+6L)/6L;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int N) {
 
  if ( (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int i = floorl(creall(cpowl((csqrtl(243.L*cpowl((long double)pc,2.L)-486.L*(long double)pc+242.L)/cpowl(3.L,(3.L/2.L))+(6.L-3.L*((-6.L*(long double)pc)+6.L))/6.L-1.L),(1.L/3.L))+1.L/(3.L*cpowl((csqrtl(243.L*cpowl((long double)pc,2.L)-486.L*(long double)pc+242.L)/cpowl(3.L,(3.L/2.L))+(6.L-3.L*((-6.L*(long double)pc)+6.L))/6.L-1.L),(1.L/3.L)))-1.L)+0.00000001);
  if ((i>=0) && ((N>=i))) {
    return i;
  }
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, N) = (%ld,%ld)\n",pc,N);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int N) {
 
  if ( ((N>=i)) && (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int j = floorl(creall(-(csqrtl(3.L)*csqrtl((-24.L*(long double)pc)+4.L*cpowl((long double)i,3.L)+24.L*cpowl((long double)i,2.L)+44.L*(long double)i+51.L)-6.L*(long double)i-9.L)/6.L)+0.00000001);
  if ((N>=i) && ((j>=0)) && ((i>=j))) {
    return j;
  }
  }
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, i, N) = (%ld,%ld, %ld)\n",pc,i,N);
  exit(1);
} /* end trahrhe_j0 */
 
/******************************** trahrhe_k0 ********************************/
static inline long int trahrhe_k0(long int pc, long int i, long int j, long int N) {
 
  if ( ((N>=i) && ((j>=0))) && (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int k = floorl(creall((6.L*(long double)pc+3.L*cpowl((long double)j,2.L)-6.L*(long double)i*(long double)j-9.L*(long double)j-cpowl((long double)i,3.L)-3.L*cpowl((long double)i,2.L)-2.L*(long double)i-6.L)/6.L)+0.00000001);
  if ((i<=N) && ((j>=0)) && (((0<=k) && (k<=i-j)))) {
    return k;
  }
  }
 
  fprintf(stderr,"Error trahrhe_k0: no corresponding domain: (pc, i, j, N) = (%ld,%ld, %ld, %ld)\n",pc,i, j,N);
  exit(1);
} /* end trahrhe_k0 */
 
