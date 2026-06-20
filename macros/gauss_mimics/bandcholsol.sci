function x = bandcholsol(b,l)
 
// PURPOSE: mimics gauss function bandcholsol: Solves the
// system of equations Ax = b for x, given the lower triangle
// of the Cholesky decomposition of a positive definite banded
// matrix A
// ------------------------------------------------------------
// INPUT:
// * b = a (K x M) matrix
// * l = a (K x M) compact form matrix
// ------------------------------------------------------------
// OUTPUT:
// * x = a (K x M) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[n,k]=size(l)
y=diag(l(:,k))
for i=1:k-1
   y=y+diag(l(k-i+1:n,i),i)
end
iy=y\eye(n,n)
x=iy*iy'*b
 
endfunction
 
