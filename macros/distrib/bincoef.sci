function [k]=bincoef(n,N)
 
// PURPOSE: generate binomial coefficients
// ------------------------------------------------------------
// INPUT:
// * n = (mxp) matrix
// * N = (nxp) matrix (same size than n) or scalar
// ------------------------------------------------------------
// OUTPUT:
// * k = (mxp) matrix of binomial coefficents with
//    - k(i,j)=binomial(n(i,j),N(i,j)) or
//    - k(i,j)=binomial(n(i,j),N) if N is a scalar
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
 
k = round(exp(gammaln(N+1)-gammaln(n+1)-gammaln(N-n+1)));
 
endfunction
