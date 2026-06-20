function r=qr_gauss(x)
 
// PURPOSE: mimic gauss function qr: Returns the r matrix in
// the QR decomposition
// ------------------------------------------------------------
// INPUT:
// * x = (N x P) matrix
// ------------------------------------------------------------
// OUTPUT:
// * r = (K x P) upper triangular matrix, K = min(N,P)
// ------------------------------------------------------------
// NOTE:
// function qr is designed to produce only the R matrix to gain
// time and memory; this is obviously not the case here...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[q,r]=qr(x)
 
endfunction
