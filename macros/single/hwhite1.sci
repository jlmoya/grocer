function [rhwhite]=hwhite1(y,x)
 
// PURPOSE: computes White's adjusted heteroscedastic
// consistent Least-squares Regression
// ------------------------------------------------------------
// References: H. White 1980, Econometrica Vol. 48 pp. 818-838.
// ------------------------------------------------------------
// INPUT:
// * y = a (n x 1) vector
// * x = a (n x k) matrix
// ------------------------------------------------------------
// OUTPUT:
// rhwhite = a tlist with
//   . rhwhite('meth')  = 'White''s heteroskedasticity
//                        consistent'
//   . rhwhite('y')     = y data vector
//   . rhwhite('x')     = x data matrix
//   . rhwhite('nobs')  = nobs
//   . rhwhite('nvar')  = nvars
//   . rhwhite('beta')  = bhat
//   . rhwhite('yhat')  = yhat
//   . rhwhite('resid') = residuals
//   . rhwhite('vcovar') = estimated variance-covariance matrix
//                         of beta
//   . rhwhite('sige')  = estimated variance of the residuals
//   . rhwhite('sige')  = estimated variance of the residuals
//   . rhwhite('ser')  = standard error of the regression
//   . rhwhite('tstat') = t-stats
//   . rhwhite('pvalue') = pvalue of the betas
//   . rhwhite('dw')    = Durbin-Watson Statistic
//   . rhwhite('prescte') = boolean indicating the presence or
//                     absence of a constant in the regression
//   . rhwhite('rsqr')  = rsquared
//   . rhwhite('rbar')  = rbar-squared
//   . rhwhite('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rhwhite('pvaluef') = its significance level
//   . rhwhite('prescte') = boolean indicating the presence or
//     absence of a time series in the regression
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
 
[nobs,nvar]=size(x)
if nvar >= nobs then
   error('too many exogenous variables')
end
 
[bet,xpxi]=ols0(y,x)
yhat=x*bet
resid=y-yhat
sigu = resid'*resid;
sige=sigu/(nobs-nvar)
ser=sqrt(sige)
// calculation of the log-likelihhod added by Nicolas Sauter (aug. 2007)
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1)
 
// perform White's correction
xuux = mcov(x,resid);
// small sample correction (Nicolas Sauter aug. 2007)
xpxia = (nobs/(nobs-nvar))*xpxi*xuux*xpxi;
tmp = sqrt(diag(xpxia));
tstat=bet ./ tmp
 
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
i=1
while (i <= nvar) & ~prescte then
   // if all values are equal to the first one then,
   // the variable is constant
   prescte=and(x(:,i) == x(1,i))
   i=i+1
end
 
rhwhite = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'yhat';'resid';'vcovar';'sige';'sigu';'ser';...
'tstat';'pvalue';'dw';'condindex';'prescte';'llike']...
,'White''s heteroskedasticity consistent',y,...
x,nobs,nvar,bet,yhat,resid,xpxia,sige,sigu,ser,tstat,...
pvalue,dw,condindex,prescte,llike)
 
 
if prescte & nvar ~=1 then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
  rhwhite=add_r2(rhwhite,sigu,ym,nobs,nvar)
end
 
endfunction
