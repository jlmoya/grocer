function [xuux]=mcov(x,u)
 
// PURPOSE: computes x'*u*u'*x
// References: H. White 1980, Econometrica Vol. 48 pp. 818-838.
//----------------------------------------------------------------
// INPUT:
// * x = nobs x nvar explanatory variables matrix
// * u = nobs x 1 residuals
//----------------------------------------------------------------
// OUTPUT:
// xuux such that xpx-inverse*xuux*xpx-inverse represents a
// heteroscedasticity consistent vcv matrix
//----------------------------------------------------------------
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to mcov');
end
 
[nobs,nvar] = size(x);
 
xuux = zeros(nvar,nvar);
 
for i = 1:nobs
  xp = x(i,:);
  xpx = xp'*xp;
  upu = u(i,1)*u(i,1);
  xuux = xuux+upu*xpx;
end
 
endfunction
