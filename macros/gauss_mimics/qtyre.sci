function [qty,r,e] = qtyre(y,x)
 
// PURPOSE: mimics gauss function qtyre: Computes the
// orthogonal-triangular (QR) decomposition of a matrix X and
// returns Q'Y and R
// ------------------------------------------------------------
// INPUT:
// * y = (N x L) matrix
// * x = (N x P) matrix
// ------------------------------------------------------------
// OUTPUT:
// * qty = (N x L) unitary matrix
// * r = (K x P) upper triangular matrix, K = min(N,P).
// * e = (P x 1) permutation vector
// ------------------------------------------------------------
// NOTE:
// function qr is designed to produce only the R matrix to gain
// time and memory; this is obviously not the case here...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[q,r,e]=qr(x)
qty=q'*y
 
endfunction
