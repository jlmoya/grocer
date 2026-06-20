function y=cdfweibull(x,k,lambda)
 
// PURPOSE: mimics Gauss function cdfweibull: computes the
// cumulative distribution function for the Weibull
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix, complementary Student’s t
//   probability levels, 0 <p < 1
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
 
[x,k,lambda]=resize(x,k,lambda)
y=1-exp(-(x ./lambda) .^k)
 
endfunction
 
