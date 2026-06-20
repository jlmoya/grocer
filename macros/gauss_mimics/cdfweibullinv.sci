function y=cdfweibullinv(p,k,lambda)
 
// PURPOSE: mimic Gauss function cdfweibullinv: computes the
// cumulative distribution function for the Weibull
// distribution
// ------------------------------------------------------------
// INPUT:
// * p = (N x K) matrix, (N x 1) vector or scalar. p must be
//   greater than 0
// * k = Shape parameter; (N x K) matrix, (N x 1) vector or
//   scalar, (E x E) conformable with x. k must be greater than
//   0
// * lambda = Scale parameter; (N x K) matrix, (N x 1) vector or
//   scalar, (E x E) conformable with x. lambda must be greater
//   than 0
// ------------------------------------------------------------
// OUTPUT:
// * y = a (N x K) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[p,k,lambda]=resize(p,k,lambda)
y=lambda .* (-log(1-p)).^(1 ./ k)
 
endfunction
 
