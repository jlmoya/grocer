function z=div(xx,yy)
 
// PURPOSE: mimics gauss division
// ------------------------------------------------------------
// INPUT:
// * orders =  vector of size of the array
// * val = value of the array
// ------------------------------------------------------------
// OUTPUT:
// * array = an array of dimensions orders and filled with the
//   value val
// ------------------------------------------------------------
// NOTE:
// gausss function diag does not work as Scialb function diag:
// if the input is avector, gauss function provides the first
// element of the vector
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
z=yy\xx;
 
endfunction
 
