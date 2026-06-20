function y = stof(x)
 
// PURPOSE: mimics gauss function stof: Converts a string to
// floating point
// ------------------------------------------------------------
// INPUT:
// * s = string, to be converted to character vector
// ------------------------------------------------------------
// OUTPUT:
// * v = (N x 1) character vector, contains the contents of s
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y=0+evstr('['+strsubst(x,' ',';')+']')
 
endfunction
