function y=%hm_tan(x)
 
// PURPOSE: define atan for hypermatrices
// ------------------------------------------------------------
// INPUT:
// * y = an hypermatrix
// * x = an hypermatrix (optional)
// ------------------------------------------------------------
// OUTPUT:
// * z = an hypermatrix of the same size
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y=matrix(tan(x(:)),size(x))
 
endfunction
