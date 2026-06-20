function l = upmat1(x)
 
// PURPOSE: mimics gauss function upmat1: Returns the upper
// portion of a matrix and a digonal of 1's
// ------------------------------------------------------------
// INPUT:
// * x = a (m x n) matrix
// ------------------------------------------------------------
// OUTPUT:
// * s = a (m x n) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[m,n]=size(x)
l=triu(x,-1)+eye(m,n)
 
endfunction
