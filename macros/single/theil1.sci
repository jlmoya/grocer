function [results]=theil1(y,x,rvec,rmat,v)
 
// PURPOSE: computes Theil-Goldberger mixed estimator
//          y = X B + E, E = N(0,sige*IN)
//          c = R B + U, U = N(0,v)
// ------------------------------------------------------------
// INPUT:
// * y = a (N X 1) vector
// * x = a (N X k) vector
// * rvec = a vector of prior mean values, (c above)
// * rmat = a matrix of rank(r)            (R above)
// * v = prior variance-covariance      (var-cov(U) above)
// ------------------------------------------------------------
// OUTPUT:
// results = a results tlist with
//   . results('meth')  = 'Theil-Goldberger'
//   . results('beta')  = bhat
//   . results('y')     = y data vector
//   . results('x')     = x data matrix
//   . results('nobs')  = # observations
//   . results('nvar')  = # variables
//   . results('yhat')  = yhat
//   . results('resid') = residuals
//   . results('vcovar') = estimated variance-covariance matrix of
//     beta
//   . results('sige')  = estimated variance of the residuals
//   . results('sigu')  = sum of squared residuals
//   . results('ser')  = standard error of the regression
//   . results('tstat') = t-stats
//   . results('pvalue') = pvalue of the betas
//   . results('dw')    = Durbin-Watson Statistic
//   . results('condindex') = multicolinearity cond index
//   . results('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019*
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
 
nobs2=size(y,1)
[nobs,nvar] = size(x);
if nvar >= nobs then
   error('too many exogenous variables')
end
if nobs~=nobs2 then
  error('x and y must have same # obs in theil');
end
 
[rsize,junk] = size(rvec);
// fill in prior means and std deviations
pstd=sqrt(diag(v))
 
vi = inv(v);
 
// do ols to get sige estimate;
bols = ols0(y,x)
sige = ((y-x*bols)')*(y-x*bols)/(nobs-nvar);
xpxi = inv(1/sige*x'*x+rmat'*vi*rmat);
xpy = 1/sige*(x'*y)+rmat'*vi*rvec;
bet=xpxi*xpy
yhat=x*bet
resid=y-yhat
sigu = resid'*resid
sige=sigu/(nobs-nvar)
ser=sqrt(sige)
vcovar = sige*diag(xpxi);
tstat=bet ./ sqrt(vcovar)
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols(x)
 
ediff = resid(2:nobs)-resid(1:nobs-1);
dw=ediff'*ediff/sigu'
// durbin-watson
 
results = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'yhat';'resid';'vcovar';'sige';'sigu';'ser';'tstat';...
'pvalue';'dw';'condindex';'prescte'],...
'Theil-Goldberger',y,x,nobs,nvar,bet,yhat,resid,vcovar,...
sige,sigu,ser,tstat,pvalue,dw,condindex,%f)
 
endfunction
