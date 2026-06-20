function [qy,r,e] = qyre(y,x)
 
// PURPOSE: mimic gauss function qtyre: Compute the
// orthogonal-triangular (QR) decomposition of a matrix X and
// returns Q*Y, R and E
// ------------------------------------------------------------
// INPUT:
// * y = (N x L) matrix
// * x = (N x P) matrix
// ------------------------------------------------------------
// OUTPUT:
// * qy = (N x L) unitary matrix
// * r = (K x P) upper triangular matrix, K = min(N,P).
// * e = permutation vector
// ------------------------------------------------------------
// NOTE:
// function qr is designed to produce only the R matrix to gain
// time and memory; this is obviously not the case here...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[q,r,e]=qr(x)
qy=q*y
 
endfunction
