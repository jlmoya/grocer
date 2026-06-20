function [p]=hypg_cdf(k,n,K,N)
 
// PURPOSE: hypergeometric cdf function
// ------------------------------------------------------------
// INPUT:
// k,n,K,N are parameters
//
// ------------------------------------------------------------
// OUTPUT:
// a vector of cumulative probabilities from the distribution
// ------------------------------------------------------------
//       Copyright (c) Anders Holtsberg
// translated to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
sn=max(size(n,1),size(n,2))
sk=max(size(K,1),size(K,2))
sN=max(size(N,1),size(N,2))
 
if (sn > 1) | (sk > 1) | (sN > 1) then
   error('Sorry, this is not implemented');
end
 
kk = -1:n;
 
cdf = max(0,min(1,cumsum(hypg_pdf(kk,n,K,N))));
p = k;
 
p(:) =cdf(max(1,min(n+2,floor(k(:))+2)))
 
endfunction
