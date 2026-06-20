function mat=rev(mat)
 
// PURPOSE: function that mimics gauss function rev: reverses
// the order of the rows of a matrix
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// OUPTUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
mat(1:$,:)=mat($:-1:1,:)
 
endfunction
 
