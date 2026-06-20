function [rols]=ols2_cons(y,x,R,r)
 
// PURPOSE: least-squarols regrolssion with constraint Rb= r
// when variables look like in the textbook
// more efficient than ols (but less user-friendly)
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// * R = a (nc x k) matrix
// * r = a (nc x 1) vector
// ------------------------------------------------------------
// OUTPUT:
// rols = a tlist with
//   . rols('meth')  = 'constrained ols'
//   . rols('y')     = y data vector
//   . rols('x')     = x data matrix
//   . rols('nobs')  = nobs
//   . rols('nvar')  = nvars
//   . rols('beta')  = bhat
//   . rols('yhat')  = yhat
//   . rols('rolsid') = rolsiduals
//   . rols('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rols('sigu')  = sum of squared rolsiduals
//   . rols('sige')  = estimated variance of the rolsiduals
//   . rols('ser')  = standard error of the regrolssion
//   . rols('tstat') = t-stats
//   . rols('pvalue') = pvalue of the betas
//   . rols('dw')    = Durbin-Watson Statistic
//   . rols('condindex') = multicolinearity cond index
//   . rols('prolscte') = boolean indicating the prolsence or
//     absence of a constant in the regrolssion
//   . rols('llike') = the log-likelihood
//   . rols('R') = the R matrix in Rb=r
//   . rols('r') = the r matrix in Rb=r
//   . rols('rsqr')  = rsquared
//   . rols('rbar')  = rbar-squared
//   . rols('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rols('pvaluef') = its significance level
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
nobs2=size(y,1)
[nrow_R,ncol_R]=size(R)
[nrow_r,ncol_r]=size(r)
[nobs,nvar] = size(x);
 
if nobs~=nobs2 then
  error('x and y must have same # obs in ols2');
end
 
if nvar >= nobs then
   error('too many exogenous variables')
end
 
if nrow_R ~= nrow_r then
   error('R and r must have the same # of rows in a constrained estiamtion')
end
 
if ncol_R ~= nvar then
   error('R and X must have the same # of cols in a constrained estiamtion')
end
 
df=nobs-nvar+nrow_r
[xpxi,xpxixp]=invxpx(x)
b0=xpxixp*y
bhat=b0+ xpxi*R'*inv(R*xpxi*R')*(r - R*b0)
yhat = x*bhat
resid = y-yhat
sigu =resid'*resid
sige= sigu/df
ser=sqrt(sige)
vcovar=sige*(xpxi*(eye(nvar,nvar)-R'*inv(R*xpxi*R')*R*xpxi))
tmp = diag(vcovar);
tstat = bhat ./ sqrt(tmp)
 
ym = y-mean0(y);
ediff = resid(2:nobs)-resid(1:nobs-1)
dw = ediff'*ediff/sigu
// durbin-watson
 
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols(x)
 
indcte=search_cte(x)
prescte=~isempty(indcte)
 
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1)
 
rols = tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'dw';'condindex';...
'prescte';'llike';'R';'r']...
,'constrained ols',y,x,nobs,nvar,bhat,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,dw,condindex,prescte,llike,R,r)
 
 
if prescte & nvar ~= 1 then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
   nvar=nvar-size(rols('R'),1)
   df=nobs-nvar
   rsqr2 = ym'*ym;
   // r-squared
   rols(1)($+1)='rsqr'
   rsqr=1-sigu/rsqr2
   rols('rsqr') =rsqr
   nobsm1=nobs-1
   nvarm1=nvar-1
   rols(1)($+1)='rbar'
   rols('rbar') = 1-sigu/df/rsqr2*nobsm1
   // rbar-squared
   if rsqr ~= 1 then
      f=rsqr/(1-rsqr)*df/(nvar-1)
   else
      warning('rsqr = 1: your exogenous variables are exactly colinear')
      f=%inf
   end
   pvaluef=1-cdff("PQ",f,nvarm1,nobs-nvar)
   rols(1)($+1)='f'
   rols('f') = f
   rols(1)($+1)='pvaluef'
   rols('pvaluef') = pvaluef
end
endfunction
