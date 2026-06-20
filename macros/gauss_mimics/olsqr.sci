function b=olsqr(y,x)
 
// PURPOSE: mimic gauss function olsqr: computes OLS
// coefficients using QR decomposition
// ------------------------------------------------------------
// INPUT:
// * y = (N x 1) vector containing dependent variable
// * x = (N x P) matrix containing independent variables
// ------------------------------------------------------------
// OUTPUT:
// * b = (P x 1) vector of least squares estimates of
//   regression of y on x. If x does not have full rank, then
//   the coefficients that cannot be estimated will be zero.
// * r = (T x 1) vector of residuals
// * p = (T x 1) vector of predicted values
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
global _olsqtol;
 
if ~exists('_olsqtol') then
   _olsqtol=1e-14
end
 
[Q,R,rk,E]=qr(x,_olsqtol)
r=R(1:rk,1:rk)
ir=inv(r)
b=E*[ir*Q(:,1:rk)'*y;zeros(size(x,2)-rk,1)]
 
endfunction
 
