function [rridge]=ridge1(y,x,theta)
 
// PURPOSE: computes Hoerl-Kennard Ridge Regression
// ------------------------------------------------------------
// REFERENCES: David Birkes, Yadolah Dodge, 1993, "Alternative
// Methods of Regression" and Hoerl, Kennard, Baldwin, 1975
// "Ridge Regression: Some Simulations', Communcations in
// Statistics
// ------------------------------------------------------------
// INPUT:
// * y = a (n x 1) vector
// * x = a (n x k) vector
// * theta = a scalr, theta's value
// ------------------------------------------------------------
// OUTPUT:
// rridge = a tlist with
//   . rridge('meth')  = 'ridge'
//   . rridge('y')     = y data vector
//   . rridge('x')     = x data matrix
//   . rridge('nobs')  = nobs
//   . rridge('nvar')  = nvars
//   . rridge('beta')  = bhat
//   . rridge('yhat')  = yhat
//   . rridge('resid') = residuals
//   . rridge('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rridge('sige')  = estimated variance of the residuals
//   . rridge('sige')  = estimated variance of the residuals
//   . rridge('ser')  = standard error of the regression
//   . rridge('tstat') = t-stats
//   . rridge('pvalue') = pvalue of the betas
//   . rridge('dw')    = Durbin-Watson Statistic
//   . rridge('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rridge('theta') = the scale factor theta
//   . rridge('rsqr')  = rsquared
//   . rridge('rbar')  = rbar-squared
//   . rridge('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rridge('pvaluef') = its significance level
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// NOTES:
// see also: rtrace
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
nobs2=size(y,1)
[nobs,nvar] = size(x);
if nobs~=nobs2 then
  error('x and y must have same # obs in ridge');
end
if nvar >= nobs then
   error('too many exogenous variables')
end
 
ridi = eye(nvar,nvar)
if isempty(theta) then
// initial values if the user has not provided one for theta
   dfs = nobs - nvar - 1;
   b=ols0(y,x)
   ridi = diag(diag(x'*x));
   dif = x*b(:,1)-y;
   ssqerr = dif'*dif;
   theta = nvar*(ssqerr/dfs)/sum((ridi.^0.5*b).^2);
end
 
// transformation of the names into variables and verification of the existence of a constant
// variable
 
xpxi = inv(x'*x+ridi*theta);
bet = xpxi*(x'*y);
 
yhat = x*bet
resid = y-yhat
sigu =resid'*resid
sige= sigu/(nobs-nvar)
ser=sqrt(sige)
vcovar=sige*xpxi
tmp = diag(vcovar);
tstat = bet ./ sqrt(tmp)
 
ym = y-mean0(y);
ediff = resid(2:nobs)-resid(1:nobs-1)
dw = ediff'*ediff/sigu
// durbin-watson
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols(x)
 
prescte=%f
if nvar ~= 1 then
   i=1
   while (i <= nvar) & ~prescte then
      // if all values are equal to the first one then,
      // the variable is constant
      prescte=and(x(:,i) == x(1,i))
      i=i+1
   end
end
 
rridge = tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'dw';'condindex';...
'prescte';'theta']...
,'ridge',y,x,nobs,nvar,bet,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,dw,condindex,prescte,theta)
 
 
if prescte then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
  rsqr1 = sigu;
  rsqr2 = ym'*ym;
  // r-squared
  rridge(1)($+1)='rsqr'
  rsqr=1-rsqr1/rsqr2
  rridge('rsqr') =rsqr
  nobsm1=nobs-1
  nvarm1=nvar-1
  rridge(1)($+1)='rbar'
  rridge('rbar') = 1-rsqr1/df/rsqr2*nobsm1
  // rbar-squared
  f=rsqr/(1-rsqr)*df/(nvar-1)
  pvaluef=1-cdff("PQ",f,nvarm1,nobs-nvar)
  rridge(1)($+1)='f'
  rridge('f') = f
  rridge(1)($+1)='pvaluef'
  rridge('pvaluef') = pvaluef
end
 
endfunction
