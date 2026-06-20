function y=cdftc(x,n)
 
// PURPOSE: mimic Gauss function cdftc: compute the
// complement of the cdf of the Student’s t distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix
// * n = a (L x M) matrix, (E x E) conformable with x.
// ------------------------------------------------------------
// OUTPUT:
// * y = max(N,L) by max(K,M) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,n]=resize(x,n)
[P,Q]=cdft("PQ",x,n)
 
endfunction
 
