#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int _PB_M, long int _PB_N) {
 
  if ((_PB_M>0)) {
    return (powl((long int)_PB_M,2L)+(long int)_PB_M)/2L;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (_PB_M, _PB_N) = (%ld, %ld)\n",_PB_M, _PB_N);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j,long int _PB_M, long int _PB_N) {
 
  if ((i>=0) && (((i<=j) && (j<_PB_M)))) {
    return (2L*(long int)j-powl((long int)i,2L)+2L*(long int)_PB_M*(long int)i-(long int)i+2L)/2L;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, _PB_M, _PB_N) = (%ld, %ld, %ld, %ld)\n",i, j,_PB_M, _PB_N);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int _PB_M, long int _PB_N) {
 
  if ((_PB_M>=1)) {
    return 1L;
  }
  return Ehrhart0(_PB_M, _PB_N);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int _PB_M, long int _PB_N) {
 
  if ((_PB_M>=1)) {
    return (powl((long int)_PB_M,2L)+(long int)_PB_M)/2L;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int _PB_M, long int _PB_N) {
 
  if ( (PCMin_10(_PB_M, _PB_N) <= pc) && (pc <= PCMax_10(_PB_M, _PB_N)) ) {
 
  long int i = floorl(creall(-(csqrtl((-8.L*(long double)pc)+4.L*cpowl((long double)_PB_M,2.L)+4.L*(long double)_PB_M+9.L)-2.L*(long double)_PB_M-1.L)/2.L)+0.00000001);
  if ((_PB_M>=i+1) && ((i>=0))) {
    return i;
  }
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, _PB_M, _PB_N) = (%ld,%ld, %ld)\n",pc,_PB_M, _PB_N);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int _PB_M, long int _PB_N) {
 
  if ( ((i>=0)) && (PCMin_10(_PB_M, _PB_N) <= pc) && (pc <= PCMax_10(_PB_M, _PB_N)) ) {
 
  long int j = floorl(creall((2.L*(long double)pc+cpowl((long double)i,2.L)-2.L*(long double)_PB_M*(long double)i+(long double)i-2.L)/2.L)+0.00000001);
  if ((i>=0) && (((i<=j) && (j<_PB_M)))) {
    return j;
  }
  }
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, i, _PB_M, _PB_N) = (%ld,%ld, %ld, %ld)\n",pc,i,_PB_M, _PB_N);
  exit(1);
} /* end trahrhe_j0 */
 
