function yy_out = MSVAR_Sort(y,bench);
 
// PURPOSE: MSVAR_Sort sort columns of a matrix according to
// the values of a bechmark vector
// ------------------------------------------------------------
// INPUT:
// * y = a (T x K) matrix of endogenous variables
// * bench = a (T x 1) vector
// ------------------------------------------------------------
// OUTPUT:
// * yy_out = the original matrix sorted by the values of the
//   vector bench
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
n_y=size(y,2);
yy=[bench y];
yy_out=sortc(yy,1);
yy_out = yy_out(:,2:n_y+1)
 
 
 
endfunction
