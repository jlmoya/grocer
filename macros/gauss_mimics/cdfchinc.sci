function c=cdfchinc(x,v,d)
 
// PURPOSE: mimic Gauss function cdfchii: computes the
// cumulative distribution function for the noncentral
// chi-square distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) vector
// * v = scalar, degrees of freedom, v > 0
// * d = scalar, noncentrality parameter, d > 0
// ------------------------------------------------------------
// OUTPUT:
// * c = a (N x 1) vector
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
c=cdfchinc("X",v,d,x,1-x)
 
endfunction
 
