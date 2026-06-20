function [rresid]=recresid(y,x)
 
// PURPOSE: compute recursive residuals
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x k)
// ------------------------------------------------------------
// OUTPUT:
// rresid = recursive residuals (first k-obs equal zero)
// ------------------------------------------------------------
// REFERENCES: A.C. Harvey, (1981) The Econometric Analysis
//              of Time-Series, pp. 54-56.
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatia-econometrics.com
 
 
[n,k] = size(x);
rresid = zeros(n,1);
b = zeros(n,k);
 
// initial estimates based on first k observations
[bt1,xxt1]=ols0(y(1:k),x(1:k,:))
b(k,:) = bt1';
j = k+1;
 
while j<=n then
  xt = x(j,1:k);
  yt = y(j,1);
  ft = 1+xt*xxt1*xt';
  xxt = xxt1-xxt1*xt'*xt*xxt1/ft;
  vt = yt-xt*bt1;
  bt = bt1+xxt1*xt'*vt/ft;
  // save results and prepare for next loop
  rresid(j,1) = vt/sqrt(ft);
  b(j,:) = bt';
  xxt1 = xxt;
  bt1 = bt;
  j = j+1;
end
 
endfunction
