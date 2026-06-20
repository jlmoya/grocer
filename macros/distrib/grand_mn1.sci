function [r] = grand_mn1(N,mu,sigma,tol)
 
// PURPOSE: draw random coefficients in multivariate normal
// law N(mu,sigma) even when sigma is (near) singular
// ------------------------------------------------------------
// INPUT:
// * N = a scalar, the # of draws
// * mu = a (m x 1) vector
// * sigma = a (m x m) variance-covariance matrix
// * tol = a scalar, the tolerance factor for the positivity of
//       matrix sigma
// ------------------------------------------------------------
// OUTPUT:
// r = a (m x N) matrix with r(:,i) drawn from N(mu,sigma)
// ------------------------------------------------------------
// NOTE: basic checks are not made: they are done in grand_nm
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
D=spec(sigma)
 
if min(D) <= tol*max(D) then
   [U,D2]=spec(sigma)
   t = (D > tol);
   D = D(t);
   T = sqrt(D) * U(:,t)';
   m=size(T,1)
   r=mu .*. ones(1,N)+T'*grand(m,N,'nor',0,1)
 
else
   r = grand(N,'mn',mu,sigma)
 
end
 
 
endfunction
