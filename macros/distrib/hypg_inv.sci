function [k]=hypg_inv(p,n,K,N)
 
// PURPOSE: hypergeometric inverse (quantile) function
// ------------------------------------------------------------
// INPUT:
// * p = a vector
// * n,K,N = parameters of the distribution
// ------------------------------------------------------------
// OUTPUT:
//        The smallest integer k so that P(X <= k) >= p.
//        a vector of probabilities from the distribution
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
if or(abs(2*p-1)>1) then
  error('A probability should be 0<=p<=1, please!');
end
 
lowerlim = max(0,n-(N-K));
upperlim = min(n,K);
kk = (lowerlim:upperlim)';
 
nk = size(kk,1);
 
cdf = max(0,min(1,cumsum(hypg_pdf(kk,n,K,N))));
 
cdf(max(size(cdf))) = 1
[pp,J] = gsort(-p(:),'g','d');pp=-pp;
np = max(size(pp));
[S,I] = gsort(-[pp;cdf],'g','i');S = -S
I = find(I<=np)'-((1:np)')+lowerlim;
J(J) = (1:np)'
p(:) = I(J);
k = p;
endfunction
