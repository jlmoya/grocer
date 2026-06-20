function [resid]=remove_trend(y,p)
 
// PURPOSE: detrend a matrix y using regression
//          of y against a polynomial time trend of order p
// ------------------------------------------------------------
// INPUT:
// * y = input matrix (or vector) of time-series (nobs x nvar)
// * p = trend degree
//   . p = 0, subtracts mean
//   . p = 1, constant plus trend model
//   . p > 1, higher order polynomial model
//   . p = -1, returns y
// ------------------------------------------------------------
// OUTPUT:
// resid = residuals from the detrending regression
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
//
// adapted to scilab from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
// error checking on input arguments
if nargin~=2 then
  error('Wrong # of arguments to detrend');
end
 
if p == -1 then
   resid = y;
 
elseif p >= 0 then
   [nobs,junk] = size(y);
   xmat = ones(nobs,p+1);
   t = 1:nobs;
   tp = t'/nobs;
   for m=1:p
      xmat(:,m+1) = tp.^m;
   end
else
  error('trend degree ('+string(p)+') should be greater or equal than -1')
end
 
bet = ols0(y,xmat);
resid = y-xmat*bet;
 
endfunction
 
