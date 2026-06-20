function [y,ind] = minc(x)
 
// PURPOSE: mimic gauss function maxindc: returns a column
// vector containing the smallest element in each column of a
// matrix
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = a (k x 1) matrix containing the smallest element in
//   each column of x
// * ind = a (k x 1) matrix containing the indexes of the
//   smallest element in each column of x (not given in Gauss
//   original function, but useful)
// ------------------------------------------------------------
// NOTE: this os not strictly equivalent to Scilab command:
// y=min(x,'c') because %nan values are ignored in gauss
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
x(isnan(x))=%inf
[y,ind]=min(x,'r')
 
endfunction
 
