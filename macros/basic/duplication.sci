function [d]=duplication(n)
 
// PURPOSE: Return Magnus and Neudecker's duplication matrix
// of size n
// ------------------------------------------------------------
// INPUT:
// * n = dimension of the underlying var-cov matrix
// ------------------------------------------------------------
// OUTPUT:
// * d = (n*n x n*(n+1)/2) duplication matrix
// ------------------------------------------------------------
// NOTE:
// used by the following functions:
// irf()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted to scilab from:
// Thomas P Minka (tpminka@media.mit.edu)
 
a = tril(ones(n,n));
i = matrix(find(a),1,-1);
 
a(i)=1:size(i,2)
a = a+tril(a,-1)';
j = vec(a);
d = zeros(n*n,n*(n+1)/2);
 
for r = 1:n*n
  d(r,j(r)) = 1;
end
 
endfunction
 
