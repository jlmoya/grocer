function y = polyeval(x,c)
 
// PURPOSE: mimic gauss function polyeval: evaluates
// polynomials. Can either be one or more scalar polynomials or
// a single matrix polynomial
// ------------------------------------------------------------
// INPUT:
// * x = a (N x N) matrix
// ------------------------------------------------------------
// OUTPUT:
// * c = (N+1)×1 vector of coefficients of the Nth order
//   characteristic polynomial of x:
//   p(z) = c(1)*z^n + c(2)*z^(n-1) + ... + c(n)*z + c(n+1)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
p=poly(c($-1:1),'x','coeff')
y=horner(p,x)
 
endfunction
