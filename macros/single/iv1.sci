function riv=iv1(y,y1,x1,xall)
 
// PURPOSE: compute instrumental variables estimation when all
// variables are in vector or matrix form
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * y1 = endogenous variables matrix (nobs x g) for this
//   equation
// * x1  = exogenous variables matrix for this equation
// * xall   = instruments for variables y1
// ------------------------------------------------------------
// OUTPUT:
// results = a results tlist with
// - riv('meth')  = 'iv'
// - riv('nobs')  = nobs
// - riv('nendog') = # of endogenous variables
// - riv('nexog')  = # of exogenous variables
// - riv('nvar')   = # of endogenous + # of exogenous
// - riv('y')      = y data vector
// - riv('beta')  = bhat estimates
// - riv('tstat') = t-statistics
// - riv('pvalue') = pvalue of
// - riv('yhat')  = yhat predicted values
// - riv('resid') = residuals
// - riv('residiv') = residuals calculated with the
//   endogenous variables replaced by their regression from
//   first stage estimation
// - riv('sigu')  = e'*e
// - riv('sige')  = e'*e/(n-k)
// - riv('ser')  = standard error of the regression
// - riv('dw')    = Durbin-Watson Statistic
// - riv('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
// - riv('condindex') = multicolinearity cond index
// - riv('raux') = a list, collecting the residuals tlists
//   from 1 stage regressions
// - riv('first stage F') = the vector of F values of the first
//   stage regressions
// - riv('rsqr')  = rsquared
// - riv('rbar')  = rbar-squared
// - riv('f')    = F-stat for the nullity of coefficients
//    other than the constant
// - riv('pvaluef') = its significance level
// - riv('grsqr')  = generalized rsquared (that is which takes
//    into account the endogeneity of the variables)
// - riv('grsqr')  = generalized rsquared (that is which takes
//    into account the endogeneity of the variables)
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2019
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
if nargin~=4 then
  error('Wrong # of arguments to iv1');
end
 
[nobs1,g] = size(y1);
[nobs2,k] = size(x1);
[nobs3,l] = size(xall);
nvar=g+k
 
if nobs2==nobs3 & (nobs1==nobs2 | nobs1==0 ) then
    if nobs2==nobs3 then
      nobs = nobs2;
   end
else
   error('iv1: # of observations in yendog, xexog, xall not the same');
end
 
if nvar >= nobs then
   error('too many exogenous variables')
end
 
// xall contains all explanatory variables
// x1 contains exogenous
// y1 contains endogenous
 
y1hat=[]
F_1st=[]
raux=list()
if nobs1 ~= 0 then
   for i=1:size(y1,2)
      raux_i=ols2(y1(:,i),xall)
      raux($+1)=raux_i
      y1hat=[y1hat ; raux_i('yhat')]
      if raux_i('prescte') then
         F_1st=[F_1st ; raux_i('f')]
      else
         F_1st=[F_1st ; (raux_i('sigu')/sum(y1hat .^ 2)-1)*nobs1/l ]
      end
   end
else
   warning('no instrumented variable')
   raux=[]
end
xhat=[y1hat x1]
[bhat,xpxi]=ols0(y,xhat)
 
// yhat
yhat = [y1,x1]*bhat
// residuals
resid = y-yhat
residiv = y - xhat*bhat
sigu = resid'*resid;
sige = sigu/(nobs-k-g)
ser=sqrt(sige)
// sige
tmp = sige*diag(xpxi);
tstat = bhat ./ sqrt(tmp)
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols([y1,x1])
 
prescte=%f
if nvar ~= 1 then
   i=1
   while (i <= nvar) & ~prescte then
      // if all values are equal to the first one then,
      // the variable is constant
      prescte=and(xhat(:,i) == xhat(1,i))
      i=i+1
   end
end
 
ediff = resid(2:nobs)-resid(1:nobs-1);
dw = ediff'*ediff/sigu
// durbin-watson
 
riv = tlist(['results';'meth';'nobs';'nendog';'nexog';'nvar';...
'y';'x';'beta';'tstat';'pvalue';'yhat';'resid';'residiv';'sigu';...
'sige';'ser';'dw';'prescte';'condindex';'auxil res';'first stage F'],...
'iv',nobs,g,k,nvar,y,xhat,bhat,tstat,pvalue,yhat,resid,residiv,...
sigu,sige,ser,dw,prescte,condindex,raux,F_1st)
 
ym = y-mean0(y);
if prescte then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
   riv=add_r2(riv,sigu,ym,nobs,nvar)
   df=nobs-nvar
   rsqr2 = ym'*ym;
// r-squared
 
   riv(1)($+1)='grsqr'
   riv(1)($+1)='grbar'
   grsqr=1-residiv'*residiv/(ym'*ym)
   riv('grsqr')=grsqr
   riv('grbar')=1-residiv'*residiv/(ym'*ym)/(nobs-nvar)*(nobs-1)
   if grsqr <0 then
      f=%nan
   elseif grsqr ~= 1 then
      f=grsqr/(1-grsqr)*df/(nvar-1)
   else
      warning('generalized rsqr = 1: your exogenous variables are exactly colinear')
      f=%inf
   end
   pvaluef=1-cdff("PQ",f,nvar-1,nobs-nvar)
   riv(1)($+1)='f'
   riv('f') = f
   riv(1)($+1)='pvaluef'
   riv('pvaluef') = pvaluef
 
end
 
endfunction
 
