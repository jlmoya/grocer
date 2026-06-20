function [xi]=invpd(x)
 
// PURPOSE: A dummy function to mimic Gauss invpd
//          simply returns the inverse, with no
//          checking for positive definiteness
//---------------------------------------------------
// INPUT:
// x = a square matrix
// --------------------------------------------------
// OUTPUT:
// xi = inverse of mat
// --------------------------------------------------
 
// tanslated by Eric Dubois from:
// http://grocer.toolbox.free.fr/grocer.html
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[n,k] = size(x);
if n~=k then
  error('invpd: matrix must be square to invert');
end
 
xi = inv(x);
 
endfunction
 
