#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int _PB_N, long int _PB_M) {
 
  if ((_PB_N>0) && ((_PB_M>0))) {
    return (long int)_PB_N*(long int)_PB_M;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (_PB_N, _PB_M) = (%ld, %ld)\n",_PB_N, _PB_M);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j,long int _PB_N, long int _PB_M) {
 
  if (((0<=i) && (i<_PB_N)) && (((0<=j) && (j<_PB_M)))) {
    return (long int)j+(long int)_PB_M*(long int)i+1L;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, _PB_N, _PB_M) = (%ld, %ld, %ld, %ld)\n",i, j,_PB_N, _PB_M);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int _PB_N, long int _PB_M) {
 
  if ((_PB_N>=1) && ((_PB_M>=1))) {
    return 1L;
  }
  return Ehrhart0(_PB_N, _PB_M);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int _PB_N, long int _PB_M) {
 
  if ((_PB_N>=1) && ((_PB_M>=1))) {
    return (long int)_PB_M*(long int)_PB_N;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int _PB_N, long int _PB_M) {
 
  if ( ((_PB_M>=1)) && (PCMin_10(_PB_N, _PB_M) <= pc) && (pc <= PCMax_10(_PB_N, _PB_M)) ) {
 
  long int i = floorl(creall(((long double)pc-1.L)/(long double)_PB_M)+0.00000001);
  if ((_PB_M>=1) && ((_PB_N>=i+1)) && ((i>=0))) {
    return i;
  }
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, _PB_N, _PB_M) = (%ld,%ld, %ld)\n",pc,_PB_N, _PB_M);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int _PB_N, long int _PB_M) {
 
  if ( ((_PB_N>=i+1) && ((i>=0))) && (PCMin_10(_PB_N, _PB_M) <= pc) && (pc <= PCMax_10(_PB_N, _PB_M)) ) {
 
  long int j = floorl(creall((long double)pc-(long double)_PB_M*(long double)i-1.L)+0.00000001);
  if (((0<=i) && (i<_PB_N)) && (((0<=j) && (j<_PB_M)))) {
    return j;
  }
  }
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, i, _PB_N, _PB_M) = (%ld,%ld, %ld, %ld)\n",pc,i,_PB_N, _PB_M);
  exit(1);
} /* end trahrhe_j0 */
 
