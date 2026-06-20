function [rnwest]=nwest1(y,x,win)
 
// PURPOSE: computes Newey-West's adjusted heteroskedastic and
// autocorrelation consistent (HAC) Least-squares Regression
// ------------------------------------------------------------
// References: W. K. Newey & K. D. West (1987)
//	"A simple, Positive Semi-Definite Positive Consistent Covariance
//	MAtrix", Econometrica, Vol. 55(3), pp. 703-708.
// ------------------------------------------------------------
// INPUT:
// * y =  a (nobs x 1) vector of an endogenous variable
// * x =  a (nobs x k) matrix of exogenous variables
// * win =  a scalar, the length of the Barlett window
// ------------------------------------------------------------
// OUTPUT:
// rnwest = a tlist with
//   . rnwest('meth')  = 'Newey-West''s HAC'
//   . rnwest('y')     = y data vector
//   . rnwest('x')     = x data matrix
//   . rnwest('nobs')  = nobs
//   . rnwest('nvar')  = nvars
//   . rnwest('beta')  = bhat
//   . rnwest('yhat')  = yhat
//   . rnwest('resid') = residuals
//   . rnwest('vcovar') = estimated variance-covariance matrix
//                         of beta
//   . rnwest('sige')  = estimated variance of the residuals
//   . rnwest('sigu')  = estimated variance of the residuals
//   . rnwest('ser')  = standard error of the regression
//   . rnwest('tstat') = t-stats
//   . rnwest('pvalue') = pvalue of the betas
//   . rnwest('dw')    = Durbin-Watson Statistic
//   . rnwest('condindex') = multicolinearity cond index
//   . rnwest('win') = truncation window
//   . rnwest('prescte') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rnwest('rsqr')  = rsquared
//   . rnwest('rbar')  = rbar-squared
//   . rnwest('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rnwest('pvaluef') = its significance level
// ------------------------------------------------------------
// Copyright: E. Michaux 2004-2013
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin < 3 then
  win = floor(5*size(y,1)^0.25)
end
 
[nobs,nvar] = size(x)
 
[bet,xpxi]=ols0(y,x)
yhat=x*bet
resid=y-yhat
sigu = resid'*resid;
sige=sigu/(nobs-nvar)
ser=sqrt(sige)
 
// perform Newey-West correction
 
emat=ones(nvar,1) .*. resid'
 
hhat=emat .* x'
xuux=hhat(:,1:nobs)*hhat(:,1:nobs)'
 
for i=1:win
   zi=hhat(:,(i+1):nobs)*hhat(:,1:nobs-i)'
   gi=zi+zi'
   xuux=xuux+(1-i/(win+1))*gi
end
 
xpxia = xpxi*xuux*xpxi;
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
if nvar ~= 1 then
   i=1
   while (i <= nvar) & ~prescte then
      // if all values are equal to the first one then,
      // the variable is constant
      prescte=and(x(:,i) == x(1,i))
      i=i+1
   end
end
 
aic=log(sigu/nobs)+nvar*2/nobs
bic=log(sigu/nobs)+nvar*log(nobs)/nobs
hq=log(sigu/nobs)+nvar*2*log(log(nobs))/nobs
 
rnwest = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'yhat';'resid';'vcovar';'sige';'sigu';'ser';...
'tstat';'pvalue';'dw';'condindex';'win';'prescte';'aic';'bic';'hq']...
,'Newey-West''s HAC',y,...
x,nobs,nvar,bet,yhat,resid,xpxia,sige,sigu,ser,tstat,...
pvalue,dw,condindex,win,prescte,aic,bic,hq)
 
 
if prescte then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
  rsqr1 = sigu;
  rsqr2 = ym'*ym;
  // r-squared
  rnwest(1)($+1)='rsqr'
  rsqr=1-rsqr1/rsqr2
  rnwest('rsqr') =rsqr
  nobsm1=nobs-1
  nvarm1=nvar-1
  rnwest(1)($+1)='rbar'
  rnwest('rbar') = 1-rsqr1/df/rsqr2*nobsm1
  // rbar-squared
  f=rsqr/(1-rsqr)*df/(nvar-1)
  pvaluef=1-cdff("PQ",f,nvarm1,nobs-nvar)
  rnwest(1)($+1)='f'
  rnwest('f') = f
  rnwest(1)($+1)='pvaluef'
  rnwest('pvaluef') = pvaluef
end
 
endfunction
