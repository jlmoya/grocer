function s=svd_gauss(x)
 
// PURPOSE: mimics gauss function svd: since the function is
// specified slighty diffrently than its Scilab homonym, a new
// function is necessary
// ------------------------------------------------------------
// INPUT:
// * x = matrix whose singular values are to be computed
// ------------------------------------------------------------
// OUTPUT:
// * s = (M x 1) vector, where M = min(N,P), containing the
// singular values of x arranged in descending order.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[u,s0,v]=svd(x)
s=diag(s0)
 
endfunction
