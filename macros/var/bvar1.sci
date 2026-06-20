function [rbvar]=bvar1(nlag,tight,weight,decay,y,x)
 
// PURPOSE: Performs a Bayesian vector autoregression of order
// nlag
// ------------------------------------------------------------
// INPUT:
// * nlag = the lag length
// * tight = Litterman's tightness hyperparameter
// * weight = Litterman's weight (matrix or scalar)
// * decay = Litterman's lag decay = lag^(-decay)
// * y = (nobs x neqs) matrix of endogenous variables
// * x = (nobs x nx) matrix of exogenous variables (optional)
// ------------------------------------------------------------
// OUTPUT:
// rbvar = a results tlist with:
//   . rbvar('meth')  = 'bvar'
//   . rbvar('y')     = y data vector
//   . rbvar('x')     = x data matrix
//   . rbvar('nvar')  = # exogenous variables
//   . rbvar('nobs')  = # observations
//   . rbvar('neqs')  = # endogenous variables
//   . rbvar('nlag')  = # lags
//   . rbvar('tight')  = Litterman's tightness hyperparameter
//   . rbvar('weight')  = Litterman's weight (matrix or scalar)
//   . rbvar('decay')  = Litterman's lag decay = lag^(-decay)
//   . rbvar('beta')  = bhat, with rbvar('beta')(:,i):
//                     coefficients for equation # i
//   . rbvar('tstat') = t-stats, with rbvar('tstat')(:,i):
//                     t-stat for equation # i
//   . rbvar('pvalue')= pvalue of the betas, with
//                      rbvar('pvalue')(:,i): p-value for
//                      equation # i
//   . rbvar('resid') = residuals, with rbvar('resid')(:,i):
//                     residuals for equation # i
//   . rbvar('yhat') = yhat, with rbvar('yhat')(:,i):
//                     residuals for equation # i
//   . rbvar('sige')  = estimated variances
//                    rbvar('sige')(i): variance for
//                    equation # i
//   . rbvar('ser')   = standard errors of the regression with
//                    rbvar('ser')(i): standard error for
//                    equation # i
//   . rbvar('dw')    = Durbin-Watson Statistic, with:
//                    rbvar('dw')(i): DW for equation # i
//   . rbvar('rsqr')  = rsquared, with rbvar('rsqr')(i) :
//                     rsquared for equation # i
//   . rbvar('rbar')  = rbar-squared
//   . rbvar('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rbvar('nx') = # exogenous variables
//   . rbvar('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rbvar('xpxi') = inv(X'X)
// ------------------------------------------------------------
// NOTE:  constant vector automatically included
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
 
if nlag<1 then
  error('Lag length less than 1 in bvar');
end
 
prt=%t
 
[nobs,neqs] = size(y);
 
if nlag>nobs then
  error('Lag length exceeds observations in bvar');
end
 
// adjust nobs to feed the lags
nobse = nobs-nlag;
 
// generate lagged rhs matrix
ylag = mlagb(y,nlag);
 
// do scaling here using fuller y-vector information
// determine scale factors using univariate AR model
 
scale = zeros(neqs,1);
scale2 = zeros(neqs,neqs);
 
for j = 1:neqs
  ytmp = y(1:nobs,j);
  scale(j,1) = scstd(ytmp,nobs,nlag);
end
 
for j = 1:neqs
   for i = 1:neqs
      scale2(i,j) = scale(j)/scale(i);
   end
end
 
// form x-matrix only up to time begf-1
if nargin == 6 then
   nx=size(x,2)
   ymat = [ylag(nlag+1:nobs,:),x];
else
   nx=0
   ymat = [ylag(nlag+1:nobs,:)];
end
 
// nvar adjusted for constant term
k = neqs*nlag+nx;
nvar = k;
 
// pull out each y-vector and run Theil-Goldberger regressions
 
bet=zeros(k,neqs)
tstat=zeros(k,neqs)
pvalue=zeros(k,neqs)
resid=zeros(nobs-nlag,neqs)
yhat=zeros(nobs-nlag,neqs)
y0=zeros(nobs-nlag,neqs)
sigu=zeros(1,neqs)
sige=zeros(1,neqs)
ser=zeros(1,neqs)
rsqr=zeros(1,neqs)
rbar=zeros(1,neqs)
pvaluef=zeros(1,neqs)
f=zeros(1,neqs)
dw=zeros(1,neqs)
 
for i = 1:neqs
  yvec = y(nlag+1:nobs,i);
  bresult = theilbv(yvec,ymat,nlag,neqs,i,tight,weight,decay,scale2,scale,nx);
 
  bet(:,i)=bresult('beta')
  // bhats
  tstat(:,i)=bresult('tstat')
  // t-stats
  pvalue(:,i)=bresult('tprob')
  // t-probs
  resid(:,i)=bresult('resid')
  // residuals
  yhat(:,i)=bresult('yhat')
  // y-hats
  // for use below
  y0(:,i)=yvec
  // y-actuals
  sigu(i)=bresult('sigu')
  // e'e/(n-k)
  sige(i)=bresult('sige')
  // e'e/(n-k)
  ser(i)=sqrt(sige(i))
  // e'e/(n-k)
  rsqr(i)=bresult('rsqr')
  // r-squared
  rbar(i)=bresult('rbar')
  // r-adjusted
  // durbin-watson
  ediff = resid(2:nobse,i)-resid(1:nobse-1,i)
  dw(i) = ediff'*ediff/sigu(i)
 
end
 
sigma=resid'*resid/(nobse-nvar)
 
rbvar = tlist(['results';'meth';'y';'nvar';'nobs';'neqs';'nlag'...
;'tight';'decay';'weight';'beta';'tstat';'pvalue';'resid';'yhat';'sige';...
'ser';'dw';'rsqr';'rbar';'sigma';'nx';'prescte';'xpxi'],...
'bvar',y,nvar,nobse,neqs,nlag,tight,decay,weight,bet,tstat,pvalue,...
resid,yhat,sige,ser,dw,rsqr,rbar,sigma,nx,%t,bresult('xpxi'))
 
if nx ~= 0 then
   rbvar(1)($+1)='x'
   rbvar($+1)=x
end
endfunction
