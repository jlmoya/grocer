function c = polymake(r)
 
// PURPOSE: mimic gauss function polymake: computes the
// coefficients of a polynomial given the roots
// ------------------------------------------------------------
// INPUT:
// * c = a (N x 1) or (1 x N) vector containing roots of the
//   desired polynomial
// ------------------------------------------------------------
// OUTPUT:
// * r = a ((N+1) x 1) vector containing the coefficients of
//   the Nth order polynomial with roots r:
//   p(z) = c(1)*z^n + c(2)*z^(n-1) + ... + c(n)*z + c(n+1)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
p=poly(r,'x','roots')
c=coeff(p)
c=c($:-1:1)
 
endfunction
