// CumNormalInv.c
// Author: Mark Broadie

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#include "HJM_type.h"

FTYPE CumNormalInv( FTYPE u );

/**********************************************************************/
static FTYPE a[4], b[4], c[9];

/// Cannot use static initializer, peripheral is not setup yet
void CumNormalInvInit() {
    a[0] =   2.50662823884;
    a[1] = -18.61500062529;
    a[2] =  41.39119773534;
    a[3] = -25.44106049637;

    b[0] =  -8.47351093090;
    b[1] =  23.08336743743;
    b[2] = -21.06224101826;
    b[3] =   3.13082909833;

    c[0] = 0.3374754822726147;
    c[1] = 0.9761690190917186;
    c[2] = 0.1607979714918209;
    c[3] = 0.0276438810333863;
    c[4] = 0.0038405729373609;
    c[5] = 0.0003951896511919;
    c[6] = 0.0000321767881768;
    c[7] = 0.0000002888167364;
    c[8] = 0.0000003960315187;
}

/**********************************************************************/
FTYPE CumNormalInv( FTYPE u )
{
  // Returns the inverse of cumulative normal distribution function.
  // Reference: Moro, B., 1995, "The Full Monte," RISK (February), 57-58.
  
  FTYPE x, r;
  
  x = u - 0.5;
  if( fabs (x) < 0.42 )
  { 
    r = x * x;
    r = x * ((( a[3]*r + a[2]) * r + a[1]) * r + a[0])/
          ((((b[3] * r+ b[2]) * r + b[1]) * r + b[0]) * r + 1.0);
    return (r);
  }
  
  r = u;
  if( x > 0.0 ) r = 1.0 - u;
  r = log(-log(r));
  r = c[0] + r * (c[1] + r * 
       (c[2] + r * (c[3] + r * 
       (c[4] + r * (c[5] + r * (c[6] + r * (c[7] + r*c[8])))))));
  if( x < 0.0 ) r = -r;
  
  return (r);
  
} // end of CumNormalInv

/**********************************************************************/
// end of CumNormalInv.c  
