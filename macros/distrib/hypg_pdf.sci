function [p]=hypg_pdf(k,n,K,N)
 
// PURPOSE: hypergeometric pdf function
// ------------------------------------------------------------
// INPUT:
// k,n,K,N are parameters or matrix with the same size
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing cdf for each x
// ------------------------------------------------------------
//       Copyright (c) Anders Holtsberg
// translated and adapted to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
if or(or(n>N|K>N|K<0)) then
  error('hypg_cdf: Incompatible input arguments');
end
 
z = k<0|(n-k)<0|k>K|(n-k)>(N-K);
I = matrix(find(~z),1,-1);
 
if (size(k,1)>1) | (size(k,2)>1) then
  k = k(I);
end
 
if (size(K,1)>1) | (size(K,2)>1) then
  K = K(I);
end
 
if (size(n,1)>1) | (size(n,2)>1) then
  n = n(I);
end
 
if (size(N,1)>1) | (size(N,2)>1) then
  N = N(I);
end
 
pp = bincoef(k,K) .* bincoef(n-k,N-K) ./ bincoef(n,N);
p = bool2s(z)*0;
 
 
p(I) = pp
endfunction
