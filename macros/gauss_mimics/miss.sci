function mat=miss(mat,val)
 
// PURPOSE: function that mimics gauss function miss: converts
// to NA prespecified values in a matrix
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// * val = a scalar
// ------------------------------------------------------------
// OUPTUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
mat(mat==val)=%nan
 
endfunction
 
