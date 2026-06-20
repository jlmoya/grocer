function y = polyroot(c)
 
// PURPOSE: mimic gauss function polymroot: computes the roots
// of the determinant of a matrix polynomial
// ------------------------------------------------------------
// INPUT:
// * c = ((N+1)*K x K) matrix of coefficients of an Nth order
//   polynomial of rank K
// ------------------------------------------------------------
// OUTPUT:
// * y = K*N vector containing the roots of the determinantal
//   equation
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y = roots(poly(c($:-1:1),"x","coef"))
 
endfunction
