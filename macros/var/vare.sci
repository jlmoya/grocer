function [resid]=vare(y,nlag,x)
 
// PURPOSE: performs vector autogressive estimation
//          and returns only residuals
// ------------------------------------------------------------
// INPUT:
// * y    = an (nobs x neqs) matrix of y-vectors
// * nlag = the lag length
// * x    = optional matrix of variables (nobs x nx)
//  (NOTE: constant vector automatically included)
// ------------------------------------------------------------
// OUTPUT:
// resid = matrix of residuals (nobs x neqs)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
[nobs,neqs] = size(y);
 
nx = 0;
 
if nargin==3 then
  [nobs2,nx] = size(x);
  if nobs2~=nobs then
    error('var: nobs in x-matrix not the same as y-matrix');
  end
end
 
// adjust nobs to feed the lags
nobse = nobs-nlag;
 
// nvar adjusted for constant term
k = neqs*nlag+1+nx;
nvar = k;
 
xlag = mlag(y,nlag);
 
// form x-matrix
if nx then
  xmat = [xlag(nlag+1:nobs,:),x(nlag+1:nobs,:),ones(nobs-nlag,1)];
else
  xmat = [xlag(nlag+1:nobs,:),ones(nobs-nlag,1)];
end
 
resid = zeros(nobse,neqs);
 
// pull out each y-vector and run regressions
for j = 1:neqs
  yvec = y(nlag+1:nobs,j);
  bet= ols0(yvec,xmat);
  resid(:,j)=yvec-xmat*bet
end
// end of loop over equations
 
endfunction
