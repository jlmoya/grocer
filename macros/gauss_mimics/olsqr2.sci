function [b,r,p]=olsqr2(y,x)
 
// PURPOSE: mimic gauss function olsqr2: computes OLS
// coefficients, residuals, and predicted values using the QR
// decomposition
// ------------------------------------------------------------
// INPUT:
// * y = (N x 1) vector containing dependent variable
// * x = (N x P) matrix containing independent variables
// ------------------------------------------------------------
// OUTPUT:
// * b = (P x 1) vector, ols coefficients
// * r = (N x 1) vector, ols residuals
// * p = (N x 1) vector, predicted values
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
if ~exists('_olsqtol') then
   _olsqtol=1e-14
end
 
[Q,R,rk,E]=qr(x,_olsqtol)
r=R(1:rk,1:rk)
ir=inv(r)
b=E*[ir*Q(:,1:rk)'*y;zeros(size(x,2)-rk,1)]
p=x*b
r=y-x*b
 
endfunction
 
