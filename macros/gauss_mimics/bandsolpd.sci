function x = bandsolpd(b,A)
 
// PURPOSE: mimic Gauss function bandsolpd: solves the system
// of equations Ax = b for x, where A is a positive definite
// banded matrix
// ------------------------------------------------------------
// INPUT:
// * b = a (K x M) matrix
// * A = a (K x N) compact form matrix
// ------------------------------------------------------------
// OUTPUT:
// * x = a (K x K) symmetrix banded matrix
// ------------------------------------------------------------
// NOTE:
// I do not know how it si programmed in gauss, but I suspect
// that the programming takes advantage of the banded form of
// the input matrix... but I have not thought enough to the
// question to propose such a programming...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
An=bandrv(A)
C=chol(An)
nC=size(C,1)
iC=C\eye(nC,nC)
x=iC*iC'*b
 
endfunction
 
