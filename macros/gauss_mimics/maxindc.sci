function y = maxindc(x)
 
// PURPOSE: mimics gauss function maxindc: returns a column
// vector containing the index (i.e., row number) of the
// maximum element in each column of a matrix
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = a (k x 1) matrix containing the index of the maximum
// element in each column of x
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[junk,y]=maxc(x)
y=y'
 
endfunction
 
