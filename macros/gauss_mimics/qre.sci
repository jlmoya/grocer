function [r,e]=qre(x)
 
// PURPOSE: mimics gauss function qre: Returns the r and
// permuation matrices in the QR decomposition
// ------------------------------------------------------------
// INPUT:
// * x = (N x P) matrix
// ------------------------------------------------------------
// OUTPUT:
// * r = (K x P) upper triangular matrix, K = min(N,P)
// * e = (P x 1) permutation vector
// ------------------------------------------------------------
// NOTE:
// function qr is designed to produce only the R and E matrix
// to gain time and memory; this is obviously not the case
// here...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[q,r,e]=qr(x)
 
endfunction
