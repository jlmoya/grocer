function x=cdftci(q,n)
 
// PURPOSE: mimic Gauss function cdftci: computes the
// complement of the cdf of the Student’s t distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix, complementary Student’s t
//   probability levels, 0 <p < 1
// * n = a (L x M) matrix, degrees of freedom, n >= 1, n needs
//  not be integral, (E x E) conformable with x
// ------------------------------------------------------------
// OUTPUT:
// * y = max(N,L) by max(K,M) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[q,n]=resize(q,n)
x=cdft("T",n,1-q,q)
 
endfunction
 
