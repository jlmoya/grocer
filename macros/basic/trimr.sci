function [z]=trimr(x,n1,n2)
 
// PURPOSE: return a matrix (or vector) x stripped of the
// specified rows.
// ------------------------------------------------------------
// INPUT:
// * x = input matrix (or vector) (n x k)
// * n1 = first n1 rows to strip
// * n2 = last n2 rows to strip
// ------------------------------------------------------------
// OUTPUT:
// * z = x(n1+1:n-n2,:)
// ------------------------------------------------------------
// NOTE:
// modelled after Gauss trimr function
// ------------------------------------------------------------
// translated by Eric Dubois from:
// http://grocer.toolbox.free.fr/grocer.html
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[n,junk] = size(x);
if (n1+n2)>=n then
  error('Attempting to trim too much in trimr');
end
h1 = n1+1;
h2 = n-n2;
z = x(h1:h2,:);
 
endfunction
 
