function y = unique_gauss(x,flag);
 
// PURPOSE: mimics gauss function uniqindx: Computes the sorted
// index of x, leaving out duplicate elements
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) or (1 x N) vector
// * flag = scalar, 1 if numeric data, 0 if character (useless
//   in Scilab)
// ------------------------------------------------------------
// OUTPUT:
// * y = a (M x 1) vector, sorted x with the duplicates removed
// ------------------------------------------------------------
// NOTE:
// The result can be different, because in gauss, the indices
// seem to be chosen radnomly
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y=unique(x)
 
endfunction
