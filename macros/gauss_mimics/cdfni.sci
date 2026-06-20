function x=cdfni(p)
 
// PURPOSE: mimic Gauss function cdfni: computes the inverse of
// the cdf of the Normal distribution
// ------------------------------------------------------------
// INPUT:
// * p = a (N x K) matrix, Normal probability levels,
//   0 < p < 1.
// ------------------------------------------------------------
// OUTPUT:
// * x = a (N x K) matrix, Normal deviates, such that
//   cdfn(x) = p
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[n,m]=size(p)
x=cdfnor("X",zeros(n,m),ones(n,m),p,1-p)
 
endfunction
 
