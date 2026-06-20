function [mlike]=ar1_like(param,y,x)
 
// PURPOSE: evaluate ols model with AR1 errors log-likelihood
// ------------------------------------------------------------
// INPUT:
// * param = parameter vector (k x 1)
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x m)
// ------------------------------------------------------------
// OUTPUT:
// mlike = a scalar equal to -log(likelihood)
// ------------------------------------------------------------
// NOTE:b(1,1) contains rho parameter
// sige is concentrated out
// ------------------------------------------------------------
// REFERENCES: Green, 1997 page 600
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
// translated to Scilab from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
 
[n,k] = size(x);
rho = param(1,1);
bet = param(2:2+k-1,1);
 
ys = y-rho*[0 ; y(1:$-1)];
xs = x-rho*[0*x(1,:) ; x(1:$-1,:)];
 
ys(1,1) = sqrt(1-rho*rho)*y(1,1);
xs(1,:) = sqrt(1-rho*rho)*x(1,:);
 
term1 = n/2*log((ys-xs*bet)'*(ys-xs*bet));
term2 = -0.5*log(1-rho*rho);
mlike = term1+term2;
 
endfunction
