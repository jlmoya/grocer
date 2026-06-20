function x=missex(x,e)
 
// PURPOSE: mimics gauss function missex: Converts numeric
// values to the missing value code according to the values
// given in a logical expression
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix
// * e = a (N x K) matrix logical matrix (matrix of 0’s and 1’s)
//   that serves as a “mask” for x; the 1’s in e correspond to
//   the values in x that are to be converted into missing
//   values
// ------------------------------------------------------------
// OUTPUT:
// * x = (N x K) matrix that equals x, but with those elements
//   that correspond to the 1’s in e converted to missing
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
x(e)=%nan
 
endfunction
 
