function y = matinit(r,c,v);
 
// PURPOSE: mimic gauss function matinit: allocates a matrix
// with a specified fill value
// ------------------------------------------------------------
// INPUT:
// * r = scalar, # of rows
// * c = scalar, # of cols
// * v = scalar, value to initialize
// ------------------------------------------------------------
// OUTPUT:
// * y = a (r x c) matrix with each element equal to the value
//   of v
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y=v*ones(r,c)
 
endfunction
 
