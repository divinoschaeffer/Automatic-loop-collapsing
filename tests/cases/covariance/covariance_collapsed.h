#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
 
/******************************** Ehrhart Polynomials ********************************/
static inline long int Ehrhart0(long int _PB_M, long int _PB_N) {
 
  if ((_PB_M>0)) {
    return (powl((long int)_PB_M,2L)+3L*(long int)_PB_M-2L*((long int)_PB_M/2L))/4L;
  }
  fprintf(stderr,"Error Ehrhart: no corresponding domain: (_PB_M, _PB_N) = (%ld, %ld)\n",_PB_M, _PB_N);
  exit(1);
}  /* end Ehrhart0 */
 
/******************************** Ranking Polynomials ********************************/
static inline long int Ranking0(long int i, long int j,long int _PB_M, long int _PB_N) {
 
  if ((i>=0) && ((j<_PB_M)) && ((2*j>=-1+_PB_M+i))) {
    return (4L*(long int)j-2L*(((long int)i+(long int)_PB_M)/2L)-powl((long int)i,2L)+2L*(long int)_PB_M*(long int)i+(long int)i-2L*((long int)_PB_M/2L)+4L)/4L;
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
    return -(2L*((2L*(long int)_PB_M-1L)/2L)-powl((long int)_PB_M,2L)-5L*(long int)_PB_M+2L*((long int)_PB_M/2L)+2L)/4L;
  }
  return 0;
} /* end PCMax_10 */
 
/******************************** trahrhe_i0 ********************************/
static inline long int trahrhe_i0(long int pc, long int _PB_M, long int _PB_N) {
 
  if ( ((_PB_M%2==0)) && (PCMin_10(_PB_M, _PB_N) <= pc) && (pc <= PCMax_10(_PB_M, _PB_N)) ) {
 
    long int i[4], rank[4];
    int MaxPC=0;
 
    i[0] = floorl(creall((-csqrtl((-4.L*(long double)pc)+cpowl((long double)_PB_M,2.L)+2.L*(long double)_PB_M+5.L))+(long double)_PB_M+1.L)+0.00000001);
    i[1] = floorl(creall((-csqrtl((-4.L*(long double)pc)+cpowl((long double)_PB_M,2.L)+2.L*(long double)_PB_M+6.L))+(long double)_PB_M+1.L)+0.00000001);
    i[2] = floorl(creall((-csqrtl((-4.L*(long double)pc)+cpowl((long double)_PB_M,2.L)+2.L*(long double)_PB_M+4.L))+(long double)_PB_M+1.L)+0.00000001);
    i[3] = floorl(creall((-csqrtl((-4.L*(long double)pc)+cpowl((long double)_PB_M,2.L)+2.L*(long double)_PB_M+5.L))+(long double)_PB_M+1.L)+0.00000001);
    for (int i=0; i<4; i++) {
      if ((_PB_M>=i[i]+1) && ((i[i]>=0)) && ((_PB_M%2==0)) && ((i[i]%2==0)))
        rank[i] = Ranking0(i[i], (_PB_M + i[i]) / 2,_PB_M, _PB_N);
      else if ((_PB_M>=i[i]+1) && ((i[i]>=0)) && (((_PB_M+1)%2==0)) && (((i[i]+1)%2==0)))
        rank[i] = Ranking0(i[i], (_PB_M + i[i]) / 2,_PB_M, _PB_N);
      else if ((_PB_M>=i[i]+1) && ((i[i]>=0)) && ((_PB_M%2==0)) && (((i[i]+1)%2==0)))
        rank[i] = Ranking0(i[i], (_PB_M + i[i] - 1) / 2,_PB_M, _PB_N);
      else if ((_PB_M>=i[i]+1) && ((i[i]>=0)) && (((_PB_M+1)%2==0)) && ((i[i]%2==0)))
        rank[i] = Ranking0(i[i], (_PB_M + i[i] - 1) / 2,_PB_M, _PB_N);
      else rank[i]=-1;
    }
    for (int i=1; i<4; i++) {
      if ((rank[i]<=pc) && (rank[i]>=rank[MaxPC])) MaxPC=i;
    }
    return i[MaxPC];
  }
 
  fprintf(stderr,"Error trahrhe_i0: no corresponding domain: (pc, _PB_M, _PB_N) = (%ld,%ld, %ld)\n",pc,_PB_M, _PB_N);
  exit(1);
} /* end trahrhe_i0 */
 
/******************************** trahrhe_j0 ********************************/
static inline long int trahrhe_j0(long int pc, long int i, long int _PB_M, long int _PB_N) {
 
  if ( ((i>=0) && ((_PB_M%2==0)) && ((i%2==0))) && (PCMin_10(_PB_M, _PB_N) <= pc) && (pc <= PCMax_10(_PB_M, _PB_N)) ) {
 
  long int j = floorl(creall((4.L*(long double)pc+cpowl((long double)i,2.L)-2.L*(long double)_PB_M*(long double)i+2.L*(long double)_PB_M-4.L)/4.L)+0.00000001);
  if (((_PB_M)%2==0