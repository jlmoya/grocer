function [rlad]=lad1(y,x,crit,maxit)
 
// PURPOSE: performs least absolute deviations regression
// ------------------------------------------------------------
// INPUT:
// * y = a (n x 1) vector
// * x = a (n x k) vector
// * crit = a scalar, the convergence criterion (for example
//   1e-5' ; default = 1e-15)
// * maxit = a scalar, the maximum # of iterations
//     (for example 'itmax=10'; default=500)
// ------------------------------------------------------------
// OUTPUT:
// rlad = a tlist with
//   . rlad('meth')  = 'lad'
//   . rlad('y')     = y data vector
//   . rlad('x')     = x data matrix
//   . rlad('nobs')  = nobs
//   . rlad('nvar')  = nvars
//   . rlad('b_new')  = bhat
//   . rlad('yhat')  = yhat
//   . rlad('resid') = residuals
//   . rlad('vcovar') = estimated variance-covariance matrix of
//     b_new
//   . rlad('sige')  = estimated variance of the residuals
//   . rlad('sigu')  = estimated sum of squared residuals
//   . rlad('ser')  = standard error of the regression
//   . rlad('tstat') = t-stats
//   . rlad('pvalue') = pvalue of the b_news
//   . rlad('dw')    = Durbin-Watson Statistic
//   . rlad('condindex') = multicolinearity cond index
//   . rlad('prescte') = boolean indicating if the R² can be
//     calculated
//   . rlad('iter')  = # of iterations
//   . rlad('conv')  = convergence max(abs(bnew-bold))
//   . rlad('weight')  = weight used to do the last ols
//                           regression
// ------------------------------------------------------------
// NOTES: minimizes sum(abs(y - x*b)) using re-iterated
//        weighted least-squares where the weights are the
//       inverse of the absolute values of the residuals
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2019
// http://grocer.toolbox.free.fr/grocer.html
// Adapated from:
// Ron Schoenberg rons@u.washington.edu
// Date: May 29, 1995 and first
// converted from Gauss code to MATLAB by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
nobs2=size(y,1)
[nobs,nvar] = size(x);
 
if nobs~=nobs2 then
  error('x and y must have same # obs in ols2');
end
 
if nvar >= nobs then
   error('too many exogenous variables')
end
 
b_old = zeros(nvar,1);
// starting values
b_new = ones(nvar,1);
iter = 0;
w = x;
convg = max(abs(b_new-b_old));
while (convg>crit)&(iter<=maxit) then
  b_old = b_new;
  b_new = invpd(w'*x)*(w'*y);
  resid = abs(y-x*b_new);
  ind = matrix(find(resid<.00001),1,-1);
  resid(ind) = .00001
  w = x ./(resid .*. ones(1,nvar));
 
  iter = iter+1;
  convg = max(abs(b_new-b_old));
end
 
yhat = x*b_new
resid = y-yhat
sigu =resid'*resid
sige= resid'*resid/(nobs-nvar)
ser=sqrt(sige)
vcovar=inv(w'*x)*nobs/(nobs-nvar)
tmp = diag(vcovar);
tstat = b_new ./ sqrt(tmp)
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
 
rlad = tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';...
'yhat';'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';...
'dw';'condindex';'prescte';'iter';'conv';'weight']...
,'lad',y,x,nobs,nvar,b_new,yhat,resid,vcovar,sige,sigu,ser,...
tstat,pvalue,dw,condindex,%f,iter,convg,w)
 
// Note: R² has no sense here since the regression is not OLS
// (it can be negative for instance !)
 
endfunction
