#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int N) {
 
  if (((0<N) && (N<=99))) {
    return (long int)infty;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (N) = (%ld)\n",N);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j, long int k,long int N) {
 
  if ((N<=99) && (((0<=i) && (i<N))) && (((i<=j) && (j<=42))) && ((k<N))) {
    return 3L*(long int)infty;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, k, N) = (%ld, %ld, %ld, %ld)\n",i, j, k,N);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int N) {
  return Ehrhart0(N);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int N) {
 
  if ((N>=44) && ((N<=99))) {
    return Caractere inconnu: :;
  }
 
  if ((N>=1) && ((N<=43))) {
    return Caractere inconnu: :;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int N) {
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, N) = (%ld,%ld)\n",pc,N);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, ,long int i, long int N) {
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, ,i, N) = (%ld,%ld, %ld, %ld)\n",pc,,i,N);
  exit(1);
} /* end trahrhe_j0 */
 
/******************************** trahrhe_k0 ********************************/
static inline long int trahrhe_k0(long int pc, ,long int i, long int j, long int N) {
 
  if ( (PCMin_10(N) <= pc) && (pc <= PCMax_10(N)) ) {
 
  long int k = floorl(creall(-(long double)infty)+0.00000001);
  if ((N<=99) && (((0<=i) && (i<N))) && (((i<=j) && (j<=42))) && ((k<N))) {
    return k;
  }
  }
 
  fprintf(stderr,"Error trahrhe_k0: no corresponding domain: (pc, ,i, j, N) = (%ld,%ld, %ld, %ld, %ld)\n",pc,,i, j,N);
  exit(1);
} /* end trahrhe_k0 */
 
