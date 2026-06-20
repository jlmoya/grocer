function c = polychar(x)
 
// PURPOSE: mimic gauss function polychar: Computes the
// characteristic polynomial of a square matrix
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
 
 
c=polymake(spec(x))
 
endfunction
