function [y,ind] = maxc(x)
 
// PURPOSE: mimics gauss function maxindc: Returns a column
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
// NOTE: this os not strictly equivalent to Scilab command:
// y=max(x,'c') because %nan values are ignored in gauss
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
x(isnan(x))=-%inf
[y,ind]=max(x,'r')
y=y'
 
endfunction
 
