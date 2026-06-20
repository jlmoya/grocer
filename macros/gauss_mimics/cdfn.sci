function n=cdfn(x)
 
// PURPOSE: mimics gauss function cdfn: computes the cdf of
// the Normal distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix
// ------------------------------------------------------------
// OUTPUT:
// * n = a (N x K) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[n,m]=size(x)
[n,Q]=cdfnor("PQ",x,zeros(n,m),ones(n,m))
 
endfunction
 
