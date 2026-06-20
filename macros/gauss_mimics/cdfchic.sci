function y=cdfchic(x,n)
 
// PURPOSE: mimics gauss function cdfchic: Computes the
// complement of the cdf of the chi-square distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix
// * n = a (L x M) matrix, confromable with X
// ------------------------------------------------------------
// OUTPUT:
// * y = max(N,L) by max(K,M) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,n]=resize(x,n)
[P,y]=cdfchi("PQ",x,n)
 
endfunction
 
