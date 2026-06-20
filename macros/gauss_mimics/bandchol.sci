function l = bandchol(a)
 
// PURPOSE: mimic Gauss function bandchol: computes the
// Cholesky decomposition of a positive definite banded matrix
// ------------------------------------------------------------
// INPUT:
// * a = a (K x N) compact form matrix
// ------------------------------------------------------------
// OUTPUT:
// * l = (K x N) compact form matrix, lower triangle of the
//   Cholesky decomposition of a
// ------------------------------------------------------------
// NOTE:
// I do not know how it si programmed in gauss, but I suspect
// that the programming takes advantage of the banded form of
// the input matrix... but I have not thought enough to the
// question to propose such a programming...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
l=band(chol(bandrv(a)),size(a,2)-1)
 
endfunction
 
