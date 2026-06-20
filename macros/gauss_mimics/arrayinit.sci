function array=arrayinit(orders,val)
 
// PURPOSE: mimic Gauss function arrayinit: creates an
// N-dimensional array with a specified fill value
// ------------------------------------------------------------
// INPUT:
// * orders =  vector of size of the array
// * val = value of the array
// ------------------------------------------------------------
// OUTPUT:
// * array = an array of dimensions orders and filled with the
//   value val
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
str='array=val*ones('+strcat('orders('+string(1:size(orders,'*')),'),')+'))'
execstr(str)
 
endfunction
 
