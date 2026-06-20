function x=rndbeta(r,c,a,b)
 
// PURPOSE: mimic gauss function rndbeta:
// computes pseudo-random numbers with gamma distribution
// ------------------------------------------------------------
// INPUT:
// * r = scalar, number of rows of resulting matrix
// * c = scalar, number of cols of resulting matrix
// * a = (M x N) matrix, (E x E) conformable with r x c
//   resulting matrix, shape parameters for beta
//   distribution
// * b = (K x L) matrix, (E x E) conformable with r x c
//   resulting matrix, shape parameters for beta
//   distribution
// ------------------------------------------------------------
// OUTPUT:
// * y =  a (r x c) matrix, beta distributed pseudo-random
//   numbers
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[a,b]=resize(a,b,ones(r,c))
x=grand(r,c,'beta',a,b)
 
endfunction
