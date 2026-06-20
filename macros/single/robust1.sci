function [rrobust]=robust1(y,x,wfunc,wparm,crit)
 
// PURPOSE: robust regression using iteratively reweighted
//          least-squares
// ------------------------------------------------------------
// INPUT:
// * y = a (n x 1) vector
// * x = a (n x k) matrix
// * wfunc = 'huber' for Huber's t function
//           'ramsay' for Ramsay's E function
//           'andrew' for Andrew's wave function
//           'tukey' for Tukey's biweight
// * wparm = weighting function parameter
// * crit = a sclar, the convergence criterion
// ------------------------------------------------------------
// OUTPUT:
// rrobust = a tlist with
//   . rrobust('meth')  = 'robust'+ 'huber', 'ramsay', 'andrew'
//                         or 'tukey'
//   . rrobust('y')     = y data vector
//   . rrobust('x')     = x data matrix
//   . rrobust('nobs')  = nobs
//   . rrobust('nvar')  = nvars
//   . rrobust('beta')  = bhat
//   . rrobust('yhat')  = yhat
//   . rrobust('resid') = residuals
//   . rrobust('vcovar') = estimated variance-covariance matrix
//                         of beta
//   . rrobust('sige')  = estimated variance of the residuals
//   . rrobust('sige')  = estimated variance of the residuals
//   . rrobust('ser')  = standard error of the regression
//   . rrobust('tstat') = t-stats
//   . rrobust('pvalue') = pvalue of the betas
//   . rrobust('dw')    = Durbin-Watson Statistic
//   . rrobust('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rrobust('rsqr')  = rsquared
//   . rrobust('rbar')  = rbar-squared
//   . rrobust('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rrobust('pvaluef') = its significance level
//   . rrobust('wparm') = wparm
//   . rrobust('iter')  = # of iterations
//   . rrobust('weight') = nobs - vector of weights
//   . rrobust('convg') = convg criterion
//   . rrobust('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rrobust('namey') = name of the y variable
//   . rrobust('namex') = name of the x variables
//   . rrobust('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rrobust('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rrobust('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
nobs2=size(y,1)
[nobs,nvar] = size(x);
if nvar >= nobs then
   error('too many exogenous variables')
end
if nobs~=nobs2 then
  error('x and y must have same # obs in ols2');
end
 
 
// find starting values
w = ones(nobs,1);
[bhat,xpxi0] = ols0(y,x)
yhat = x*bhat;
resid = y-yhat;
 
scale = median(abs(resid-median(resid)))/.6745;
 
convg = 1;
cnt = 0;
 
while convg > crit then
 
  bhato = bhat;
  resid = resid/scale;
  cnt = cnt+1;
 
  select wfunc
  case 'huber' then
    // Huber's t function
    w = wparm*ones(nobs,1) ./ abs(resid);
    is_smallresid=(w>=1)
    wi =find(is_smallresid);
    w(wi) = 1
    psi_deriv=bool2s(is_smallresid)
    psi=resid.*psi_deriv+wparm*sign(resid).*(1-psi_deriv)
 
  case 'ramsay' then
    // Ramsay's E function
    w = exp(-wparm*abs(resid));
    psi=resid .* w
    psi_deriv=w -wparm*sign(resid).*psi
 
  case 'andrew' then
    // Andrew's wave function
    resid_new=resid/wparm
    resid_new(resid_new==0)=1
    wi = bool2s(abs(resid_new)>%pi);
    psi=wparm*sin(resid_new).*(1-wi)
    w = psi ./ resid_new;
    w(resid_new==0)=1
    psi_deriv=cos(resid_new).*(1-wi)
 
  case 'tukey' then
    // Tukey's biweight
    w = (1-(resid/wparm).^2).^2;
    wi = find(abs(resid)>wparm);
    w(wi) = 0
    psi=resid.*w
    psi_deriv=w-4*resid .^2 .*(1-(resid/wparm).^2)/wparm^2
 
 
  else
    error('incorrect weight function option');
  end
 
  // do weighted least-squares
  ystar = y .* sqrt(w);
  xstar = x .* (ones(1,nvar) .*. sqrt(w));
  [bet,xpxi]=ols0(ystar,xstar)
  yhat=x*bet;
  resid = y-yhat;
 
  // check for convergence
  convg = max(abs(bhat-bhato) ./ abs(bhato));
 
end
// end of while loop
 
 
yhat=x*bet
psi_deriv_mean=sum(psi_deriv)/nobs
vcovar=nobs*scale^2/(nobs-nvar)*sum(psi.^2)/psi_deriv_mean^2;
tstat=bet ./ sqrt(diag(vcovar))
sigu=resid'*resid
sige=sigu/(nobs-nvar)
ser=sqrt(sige)
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
 
 
rrobust = tlist(['results';'meth';'y';'x';'nobs';'nvar'...
;'beta';'yhat';'resid';'vcovar';'sige';'sigu';'ser'...
;'tstat';'pvalue';'dw';'condindex';'prescte';'wparm'...
;'iter';'weight';'convg'],'robust '+wfunc,y,x,nobs,nvar...
,bet,yhat,resid,vcovar,sige,sigu,ser,tstat,pvalue,dw,...
condindex,%f,wparm,cnt,w,convg)
 
// Note: R� has no sense here since the regression is not OLS
// (it can be negative for instance !)
 
endfunction
