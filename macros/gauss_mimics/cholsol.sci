function x = cholsol(b,C)
 
// PURPOSE: mimic Gauss function cholsol: solves a system of
// linear equations given the Cholesky factorization of the
// system
// ------------------------------------------------------------
// INPUT:
// * b = a (N x K) matrix
// * C = a (N x N) matrix
// ------------------------------------------------------------
// OUTPUT:
// * x = a a (N x K) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
iC=inv(C)
x=iC*iC'*b
 
endfunction
