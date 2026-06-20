function y = seqm(start,inc,n)
 
// PURPOSE: mimics gauss function seqm: creates a
// multiplicative sequence
// ------------------------------------------------------------
// INPUT:
// * start = scalar specifying the first element
// * inc = scalar specifying increment
// * n = scalar specifying the number of elements in the
//   sequence
// ------------------------------------------------------------
// OUTPUT:
// y = a (n x 1) vector containing the specified sequence
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
y=start*inc^[0:n-1]'
 
endfunction
