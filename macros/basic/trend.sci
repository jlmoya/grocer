function [xmat]=trend(p,nobs)
 
// PURPOSE: produce a vector equal to a time-trend with exponentiation p
// exponentiation p
// ----------------------------------------------------
// INPUT:
// * p = exponent of the time-trend
// * nobs = size of the matrix
// ----------------------------------------------------
// OUTPUT:
// xmat =  (nobsx1) vector containing polynomial trend
// ----------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
 
xmat= [1:nobs]'.^p
 
endfunction
 
