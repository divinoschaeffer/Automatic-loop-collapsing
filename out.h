#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int N) {
 
  if ((N>=2)) {
    return (powl((long int)N,3L)-powl((long int)N,2L))/2L;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (N) = (%ld)\n",N);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j, long int k,long int N) {
 
  if ((i>=0) && (((i<j) && (j<N))) && (((0<=k) && (k<N)))) {
    return (2L*(long int)k+2L*(long int)N*(long int)j+(long int)i*((long int)N*(2L*(long int)N-3L)-(long int)N*(long int)i)-2L*(long int)N+2L)/2L;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, k, N) = (%ld, %ld, %ld, %ld)\n",i, j, k,N);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int N) {
 
  if ((N>=2)) {
    return Caractere inconnu: :;
  }
  return Ehrhart0(N);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int N) {
 
  if ((N>=2)) {
    return Caractere inconnu: :;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int N) {
 
  if ( (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int i = Caractere inconnu: 0;
  if ((N>=i+2) && ((i>=0))) {
    return i;
  }
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, N) = (%ld,%ld)\n",pc,N);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int N) {
 
  if ( ((i>=0)) && (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int j = floorl(creall(1.L)+0.00000001);
  if ((i>=0) && ((j>=i+1)) && ((N>=j+1))) {
    return j;
  }
  }
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, i, N) = (%ld,%ld, %ld)\n",pc,i,N);
  exit(1);
} /* end trahrhe_j0 */
 
/******************************** trahrhe_k0 ********************************/
static inline long int trahrhe_k0(long int pc, long int i, long int j, long int N) {
 
  if ( ((i>=0) && ((j>=i+1)) && ((N>=j+1))) && (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int k = floorl(creall((2.L*(long double)pc-2.L*(long double)N*(long double)j+(long double)i*((long double)N*(long double)i+(3.L-2.L*(long double)N)*(long double)N)+2.L*(long double)N-2.L)/2.L)+0.00000001);
  if ((i>=0) && (((i<j) && (j<N))) && (((0<=k) && (k<N)))) {
    return k;
  }
  }
 
  fprintf(stderr,"Error trahrhe_k0: no corresponding domain: (pc, i, j, N) = (%ld,%ld, %ld, %ld)\n",pc,i, j,N);
  exit(1);
} /* end trahrhe_k0 */
 
