function mat=packr(mat)
 
// PURPOSE: function that mimics gauss function packr: deletes
// the rows of a matrix that contain any missing values
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// OUPTUT:
// * mat = a (mxp) vector with m <= n
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
mat(or(isnan(mat),'c'),:)=[]
 
endfunction
 
