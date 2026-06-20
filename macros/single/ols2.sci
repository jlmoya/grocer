function [rols]=ols2(y,x)
 
// PURPOSE: least-squares regression when variables
// looks like in the textbook
// more efficient than ols (but less user-friendly)
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// ------------------------------------------------------------
// OUTPUT:
// rols = a tlist with
//   . rols('meth')  = 'ols'
//   . rols('y')     = y data vector
//   . rols('x')     = x data matrix
//   . rols('nobs')  = nobs
//   . rols('nvar')  = nvars
//   . rols('beta')  = bhat
//   . rols('yhat')  = yhat
//   . rols('resid') = residuals
//   . rols('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rols('sigu')  = sum of squared residuals
//   . rols('sige')  = estimated variance of the residuals
//   . rols('ser')  = standard error of the regression
//   . rols('tstat') = t-stats
//   . rols('pvalue') = pvalue of the betas
//   . rols('dw')    = Durbin-Watson Statistic
//   . rols('condindex') = multicolinearity cond index
//   . rols('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rols('llike') = the log-likelihood
//   - rols('aic')= the Akaike information criterion
//   - rols('bic')= the Schwarz information criterion
//   - rols('hq')= the Hannan-Quinn information criterion
//   . rols('rsqr')  = rsquared
//   . rols('rbar')  = rbar-squared
//   . rols('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rols('pvaluef') = its significance level
// ------------------------------------------------------------
// NOTES:
// * used by ols(), olsc()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
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
  error('x and y must have same # obs in ols2');
end
if nvar >= nobs then
   error('too many exogenous variables')
end
 
[xpxi,xpxixp]=invxpx(x)
bhat=xpxixp*y
yhat = x*bhat
resid = y-yhat
sigu =sum(resid .^2)
sige= sigu/(nobs-nvar)
ser=sqrt(sige)
vcovar=sige*xpxi
tstat = bhat ./ sqrt(diag(vcovar))
ym = y-mean0(y);
ediff = resid(2:nobs)-resid(1:nobs-1)
dw = ediff'*ediff/sigu // durbin-watson
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols(x)
 
indcte=search_cte(x)
prescte=~isempty(indcte)
 
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1)
aic=log(sigu/nobs)+nvar*2/nobs
bic=log(sigu/nobs)+nvar*log(nobs)/nobs
hq=log(sigu/nobs)+nvar*2*log(log(nobs))/nobs
 
rols = tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'dw';'condindex';...
'prescte';'llike';'aic';'bic';'hq']...
,'ols',y,x,nobs,nvar,bhat,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,dw,condindex,prescte,llike,aic,bic,hq)
 
 
if prescte & nvar ~=1 then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
  [rols]=add_r2(rols,sigu,ym,nobs,nvar)
end
 
endfunction
