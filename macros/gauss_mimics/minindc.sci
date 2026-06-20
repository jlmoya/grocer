function y = minindc(x)
 
// PURPOSE: mimics gauss function minindc: returns a column
// vector containing the index (i.e., row number) of the
// minimum element in each column of a matrix
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = a (k x 1) matrix containing the index of the minimum
// element in each column of x
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[junk,y]=minc(x)
y=y'
 
endfunction
 
