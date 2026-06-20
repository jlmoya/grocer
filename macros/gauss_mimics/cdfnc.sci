function nc=cdfnc(x)
 
// PURPOSE: mimic Gauss function cdfnc: computes 1 minus the
// cdf of the Normal distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix
// ------------------------------------------------------------
// OUTPUT:
// * nc = a (N x K) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[n,m]=size(x)
[P,nc]=cdfnor("PQ",x,zeros(n,m),ones(n,m))
 
endfunction
 
