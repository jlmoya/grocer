function [rols]=ols1(y,x)
 
// PURPOSE: one of the numerous functions performing ordinary
// least squares: this one assumes that x et y are already a
// matrix and a vector and does not provide DW, R² statistics
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// ------------------------------------------------------------
// OUTPUT:
// a tlist with:
//        rols('meth')  = 'ols'
//        rols('y')     = y data vector
//        rols('x')     = x data matrix
//        rols('nobs')  = nobs
//        rols('nvar')  = nvars
//        rols('beta')  = bhat
//        rols('tstat') = t-stats
//        rols('pvalue') = pvalue of the betas
//        rols('resid') = residuals
//        rols('vcovar') = estimated variance-covariance matrix
//        of beta
//        rols('sige')  = estimated variance of the residuals
//        rols('sigu')  = sum of squared residuals
//        rols('ser')  = standard error of the regression
//        rols('yhat')  = yhat
// ------------------------------------------------------------
// NOTES:
// used by automatic(), kpss()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
nobs2=size(y,1)
[nobs,nvar] = size(x);
if nobs~=nobs2 then
  error('x and y must have same # obs in ols1');
end
if nvar >= nobs then
   error('too many exogenous variables')
end
 
[xpxi,xpxixp]=invxpx(x)
bhat=xpxixp*y
yhat = x*bhat
resid = y-yhat
sigu =resid'*resid
sige= sigu/(nobs-nvar)
ser=sqrt(sige)
vcovar=sige*xpxi
tmp = diag(vcovar);
tstat = bhat ./ sqrt(tmp)
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
rols = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'tstat';'pvalue';'resid';'vcovar';'sige';'sigu';...
'ser';'yhat'],'ols1',y,x,nobs,nvar,bhat,tstat,pvalue,resid,...
vcovar,sige,sigu,ser,yhat)
endfunction
