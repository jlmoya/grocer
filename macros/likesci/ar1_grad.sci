function [grad]=ar1_grad(param,y,x)
 
// PURPOSE: evaluate minus the gradient of the log-likelihood
// for ols model with AR1 errors
// ------------------------------------------------------------
// INPUT:
// * param = parameter vector (k x 1)
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x m)
// ------------------------------------------------------------
// OUTPUT:
// grad = the gradient
// ------------------------------------------------------------
// NOTE: param(1,1) contains rho parameter
// ------------------------------------------------------------
// REFERENCES: Green, 1997 page 600
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[n,k] = size(x);
rho = param(1,1);
bet = param(2:k+1,1);
grad=ones(k+1,1)
 
ys = y-rho*[0 ; y(1:n-1)];
xs = x-rho*[0*x(1,:) ; x(1:n-1,:)];
ys(1,1) = sqrt(1-rho*rho)*y(1,1);
xs(1,:) = sqrt(1-rho*rho)*x(1,:);
 
res=y-x*bet
rest=ys-xs*bet
nsigma2=rest'*rest
 
grad(1)=-n*(rho*res(1)^2+res(1:n-1)'*rest(2:n))/nsigma2+rho/(1-rho^2)
grad(2:k+1)=-n*(xs'*rest)/nsigma2
 
endfunction
