function y=diag_gauss(x)
 
// PURPOSE: mimics Gauss function diag: creates a column vector
// from the diagonal of a matrix
// ------------------------------------------------------------
// INPUT:
// * x =  (N x K) matrix or L-dimensional array where the last
// two dimensions are N x K
// ------------------------------------------------------------
// OUTPUT:
// * y = (min(N,K) x 1) vector or L-dimensional array where the
// last two dimensions are min(N,K) x1
// ------------------------------------------------------------
// NOTE:
// gausss function diag does not work as Scialb function diag:
// if the input is a vector, gauss function provides the first
// element of the vector
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
min_dims=min(size(x))
y=diag(x(1:min_dims,1:min_dims))
 
endfunction
 
