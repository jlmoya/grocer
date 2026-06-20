function v=meanc(mat)
 
// PURPOSE: function that mimics gauss function meanc: takes
// the mean of each column of a matrix and stores it in a
// column
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// ------------------------------------------------------------
// OUPTUT:
// * v = a (px1) vector
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
v=mean(mat,'r')'
 
endfunction
 
