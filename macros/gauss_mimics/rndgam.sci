function x=rndgam(r,c,alpha)
 
// PURPOSE: mimic gauss function rndgam: computes pseudo-random
// numbers with gamma distribution
// ------------------------------------------------------------
// INPUT:
// * r = scalar, number of rows of resulting matrix
// * c = scalar, number of cols of resulting matrix
// * alpha = (M x N) matrix, (E x E) conformable with r x c
//   resulting matrix, shape parameters for gamma
//   distribution
// ------------------------------------------------------------
// OUTPUT:
// * y =  (r x c) matrix, gamma distributed pseudo-random
//   numbers
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
alpha=resize(alpha,ones(r,c))
x=grand(r,c,'gam',alpha,ones(r,c))
 
endfunction
