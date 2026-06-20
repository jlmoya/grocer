function [d]=elimination(n)
 
// PURPOSE: Return Magnus and Neudecker's elimination matrix
// of size n
// ------------------------------------------------------------
// INPUT:
// n = the size of the underlying var_cov matrix
// ------------------------------------------------------------
// OUTPUT:
// d = the elimination matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
a = tril(ones(n,n));
i = matrix(find(a),1,-1);
 
d = zeros(n*(n+1)/2,n*n);
 
for r = 1:n*(n+1)/2
  d(r,i(r)) = 1;
end
 
endfunction
 
