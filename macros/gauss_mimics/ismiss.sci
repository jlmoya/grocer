function y=ismiss(x)
 
// PURPOSE: mimic gauss function ismiss: returns a 1 if its
// matrix argument contains any missing values, otherwise
// returns a 0.
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = 0 if there is a NA value in x
//     = 1 if there is no NA value in x
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y = bool2s(or(isnan(x)))
 
endfunction
 
