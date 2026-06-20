function y=cdffnc_gauss(x,n1,n2,d)
 
// PURPOSE: mimic Gauss function cdffnc: computes the
// cumulative distribution function of the noncentral F
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) vector, values of upper limits of
//   integrals, x > 0
// * n1 = scalar, degrees of freedom of numerator, n1 > 0.
// * n2 = scalar, degrees of freedom of denominator, n1 > 0.
// * d = scalar, noncentrality parameter, d > 0
// ------------------------------------------------------------
// OUTPUT:
// * y = a (N x 1) vector
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
n1=n1+0*x
n2=n2+0*x
d=d+0*x
[y,Q]=cdffnc("PQ",x,n1,n2,d^2)
 
endfunction
 
