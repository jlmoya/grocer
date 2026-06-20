function y = boxcox(x,lambda)
 
// PURPOSE: mimic Gauss function boxcox: computes the Box-Cox
// function
// ------------------------------------------------------------
// INPUT:
// * x = a (M x N) matrix or P-dimensional array where the last
//   two dimensions are (M x N)
// * lambda = a (L x M) matrix or P-dimensional array where the last
//   two dimensions are (L x M), (E x E) conformable with n.
// ------------------------------------------------------------
// OUTPUT:
// * y = a max(N,L) by max(K,M) matrix or P-dimensional array
//   where the last two dimensions are max(N,L) by max(K,M)
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
[x,lambda]=resize(x,lambda)
y=(x .^ lambda -1)./lambda
 
endfunction
 
