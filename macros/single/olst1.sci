function [rolst]=olst1(y,x,crit,maxit)
 
// PURPOSE: ols with t-distributed errors
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
// rolst = a tlist with
//   . rolst('meth')  = 'olst'
//   . rolst('y')     = y data vector
//   . rolst('x')     = x data matrix
//   . rolst('nobs')  = nobs
//   . rolst('nvar')  = nvars
//   . rolst('beta')  = bhat
//   . rolst('yhat')  = yhat
//   . rolst('resid') = residuals
//   . rolst('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolst('sige')  = estimated variance of the residuals
//   . rolst('sigu')  = estimated sum of squared residuals
//   . rolst('ser')  = standard error of the regression
//   . rolst('tstat') = t-stats
//   . rolst('pvalue') = pvalue of the betas
//   . rolst('dw')    = Durbin-Watson Statistic
//   . rolst('condindex') = multicolinearity cond index
//   . rolst('conv')  = convergence max(abs(bnew-bold))
//   . rolst('iter')  = # of iterations
//   . rolst('prescte') = boolean indicating if the R² can be
//     calculated
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// NOTES: uses iterated re-weighted least-squares
//        to find maximum likelihood estimates
// ------------------------------------------------------------
// REFERENCES: Section 22.3 Introduction to the Theory and
// Practice of Econometrics, Judge, Hill, Griffiths, Lutkepohl,
// Lee
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2019
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nobs,nvar] = size(x);
[nobs2] = size(y,1);
 
if nobs~=nobs2 then
  error('x and y must have same # obs');
end
if nvar >= nobs then
   error('too many exogenous variables')
end
 
iota = ones(nobs,1);
bmle = ols0(y,x);
// use ols starting values
iter = 1;
nu = 1;
convg = max(abs(bmle));
while ((convg>crit)&(iter<=maxit)) | iter == 1 then
  emle = y-x*bmle;
  sige2 = emle'*emle/nobs;
  nusig2 = (nu+1)*sige2;
  wt = iota+emle .* emle/nusig2;
  wx = x ./ (ones(1,nvar) .*. wt)
  wy = y ./ wt;
  b_new = inv(x'*wx)*(x'*wy);
  convg = max(abs(bmle-b_new));
  bmle = b_new;
  iter = iter+1;
end
 
if convg > crit then
   warn('iteration limit reached in olst')
end
 
yhat=x*bmle
resid=y-yhat
sigu =resid'*resid
sige= sigu/(nobs-nvar)
ser=sqrt(sige)
vcovar=((nu+3)*nusig2/(nu+1))*invxpx(x);
tmp = diag(vcovar);
tstat=bmle ./ sqrt(tmp)
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols(x)
 
ediff = resid(2:nobs)-resid(1:nobs-1);
dw=ediff'*ediff/sigu'
 
rolst = tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';...
'yhat';'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';...
'dw';'condindex';'conv';'iter';'prescte']...
,'olst',y,x,nobs,nvar,bmle,yhat,resid,vcovar,sige,sigu,ser,...
tstat,pvalue,dw,condindex,convg,iter,%f)
 
endfunction
