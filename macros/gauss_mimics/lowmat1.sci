function l = lowmat1(x)
 
// PURPOSE: mimic gauss function lowmat1: returns the lower
// portion of a matrix and a digonal of 1's
// ------------------------------------------------------------
// INPUT:
// * x = (m x n) matrix
// ------------------------------------------------------------
// OUTPUT:
// * l = (m x n) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[m,n]=size(x)
l=tril(x,-1)+eye(m,n)
 
endfunction
