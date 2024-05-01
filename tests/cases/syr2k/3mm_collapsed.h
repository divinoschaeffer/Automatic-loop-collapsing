#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int _PB_NI, long int _PB_NJ, long int _PB_NK, long int _PB_NL, long int _PB_NM) {
 
  if ((_PB_NI>0) && ((_PB_NJ>0))) {
    return (long int)_PB_NI*(long int)_PB_NJ;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM) = (%ld, %ld, %ld, %ld, %ld)\n",_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j,long int _PB_NI, long int _PB_NJ, long int _PB_NK, long int _PB_NL, long int _PB_NM) {
 
  if (((0<=i) && (i<_PB_NI)) && (((0<=j) && (j<_PB_NJ)))) {
    return (long int)j+(long int)_PB_NJ*(long int)i+1L;
  }
  fprintf(stderr,"Error Ranking: no corresponding domain: (i, j, _PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM) = (%ld, %ld, %ld, %ld, %ld, %ld, %ld)\n",i, j,_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM);
  exit(1);
} /* end Ranking0 */
 
/******************************** PCMin ********************************/
/******************************** PCMin_10 ********************************/
static inline long int PCMin_10(long int _PB_NI, long int _PB_NJ, long int _PB_NK, long int _PB_NL, long int _PB_NM) {
 
  if ((_PB_NI>=1) && ((_PB_NJ>=1))) {
    return 1L;
  }
  return Ehrhart0(_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM);
} /* end PCMin_10 */
 
/******************************** PCMax ********************************/
/******************************** PCMax_10 ********************************/
static inline long int PCMax_10(long int _PB_NI, long int _PB_NJ, long int _PB_NK, long int _PB_NL, long int _PB_NM) {
 
  if ((_PB_NI>=1) && ((_PB_NJ>=1))) {
    return (long int)_PB_NI*(long int)_PB_NJ;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int _PB_NI, long int _PB_NJ, long int _PB_NK, long int _PB_NL, long int _PB_NM) {
 
  if ( ((_PB_NJ>=1)) && (PCMin_10(_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM) <= pc) && (pc <= PCMax_10(_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM)) ) {
 
  long int i = floorl(creall(((long double)pc-1.L)/(long double)_PB_NJ)+0.00000001);
  if ((_PB_NJ>=1) && ((_PB_NI>=i+1)) && ((i>=0))) {
    return i;
  }
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, _PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM) = (%ld,%ld, %ld, %ld, %ld, %ld)\n",pc,_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int _PB_NI, long int _PB_NJ, long int _PB_NK, long int _PB_NL, long int _PB_NM) {
 
  if ( ((_PB_NI>=i+1) && ((i>=0))) && (PCMin_10(_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM) <= pc) && (pc <= PCMax_10(_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM)) ) {
 
  long int j = floorl(creall((long double)pc-(long double)_PB_NJ*(long double)i-1.L)+0.00000001);
  if (((0<=i) && (i<_PB_NI)) && (((0<=j) && (j<_PB_NJ)))) {
    return j;
  }
  }
 
  fprintf(stderr,"Error trahrhe_j0: no corresponding domain: (pc, i, _PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM) = (%ld,%ld, %ld, %ld, %ld, %ld, %ld)\n",pc,i,_PB_NI, _PB_NJ, _PB_NK, _PB_NL, _PB_NM);
  exit(1);
} /* end trahrhe_j0 */
 
