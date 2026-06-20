function v=stdc(mat)
 
// PURPOSE: function that mimics gauss function stdc: takes
// the standard deviations of each column of a matrix and stores
// them in a column
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// OUPTUT:
// * v = a (px1) vector
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
v=st_dev(mat,'r')'
 
endfunction
 
