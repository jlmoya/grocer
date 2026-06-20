function mat=missrv(mat,val)
 
// PURPOSE: function that mimics gauss function missrv:
// converts NA to prespecified values in a matrix
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// * val = a scalar
// ------------------------------------------------------------
// OUPTUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
mat(isnan(mat))=val
 
endfunction
 
