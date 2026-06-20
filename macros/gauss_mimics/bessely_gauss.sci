function y = bessely_gauss(n,x)
 
// PURPOSE: mimic Gauss function bessely: computes a Bessel
// function of the second kind (Weber’s function), Yn(x)
// ------------------------------------------------------------
// INPUT:
// * n = a (N x K) matrix or P-dimensional array where the last
//   two dimensions are (N x K), the order of the Bessel
//   function. Nonintegers will be truncated to an integer
// * x = a (L x M) matrix or P-dimensional array where the last
//   two dimensions are (L x M), (E x E) conformable with n.
// ------------------------------------------------------------
// OUTPUT:
// * y = a max(N,L) by max(K,M) matrix or P-dimensional array
//   where the last two dimensions are max(N,L) by max(K,M)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[n,x]=resize(n,x)
y=bessely(n,x)
 
endfunction
 
