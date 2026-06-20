function c=cdfchii(p,n)
 
// PURPOSE: mimic Gauss function cdfchii: computes chi-square
// abscissae values given probability and degrees of freedom
// ------------------------------------------------------------
// INPUT:
// * p = a (M x N) matrix
// * n = a (L x K) matrix
// ------------------------------------------------------------
// OUTPUT:
// * c = max(M,L) by max(N,K) matrix, abscissae values for
// chi-squared distribution
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nx,mx]=size(x)
[p,n]=resize(p,n)
c=cdfchi("X",n,p,1-p)
 
endfunction
 
