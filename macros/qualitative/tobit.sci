function [rtobit]=tobit(grocer_namey0,varargin)
 
// PURPOSE: computes Tobit Regression
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nx1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . a string option which can be:
//      - 'trunc=left' or 'trunc=right' for censoring
//        (default=left)
//      - 'vtrunc=x' where x is the value for censoring
//        (default=0)
//      - 'b0=x' where x is the starting values for parameters
//        (default = ols)
//      - 'hess=x' where x = Hessian: 'dfp', 'bfgs', 'gn',
//         'marq', 'sd' (default = bfgs)
//      - 'btol=x' where x is the tolerance for b convergence
//         (default = 1e-8)
//      - 'ftol=x' tolerance for FUN convergence
//        (default = 1e-8)
//      - 'maxit=x' is the maximum # of iterations
//        (default = 500)
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
// ------------------------------------------------------------
// OUTPUT:
// rtobit = a results tlist with
//   . rtobit('meth')  = 'tobit'
//   . rtobit('y')     = y data vector
//   . rtobit('x')     = x data matrix
//   . rtobit('nobs')  = # observations
//   . rtobit('nobsc')  = # censored observations
//   . rtobit('nvar')  = # variables
//   . rtobit('beta')  = bhat
//   . rtobit('yhat')  = yhat
//   . rtobit('resid') = residuals
//   . rtobit('vcovar') = estimated variance-covariance matrix
//     of beta
//   . rtobit('sige')  = estimated variance of the residuals
//   . rtobit('sigu')  = sum of squared residuals
//   . rtobit('ser')  = standard error of the regression
//   . rtobit('tstat') = t-stats
//   . rtobit('pvalue') = pvalue of the betas
//   . rtobit('dw')    = Durbin-Watson Statistic
//   . rtobit('condindex') = multicolinearity cond index
//   . rtobit('prescte') = %f = boolean indicating the absence
//     of a constant in the regression
//   . rtobit('iter') = # iterations performed
//   . rtobit('llike') = log likelihood
//   . rtobit('opthess') = option used to update hessian
//   . rtobit('grad') = gradient at the optimum
//   . rtobit('ts') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rtobit('namey') = name of the y variable
//   . rtobit('namex') = name of the x variables
//   . rtobit('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rtobit('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rtobit('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
// set defaults
grocer_trunc='left'
grocer_vtrunc=0
grocer_prt=%t
grocer_dropna=%f
grocer_nargin=length(varargin)
grocer_lx0=varargin
 
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      str7=part(varargin(grocer_i),[1:7])
      str2=part(varargin(grocer_i),[1:2])
      str4=part(varargin(grocer_i),[1:4])
      str5=part(varargin(grocer_i),[1:5])
      str6=part(varargin(grocer_i),[1:6])
      if str5 == 'trunc' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
         grocer_lx0(grocer_i)=null()
      elseif str6 == 'vtrunc' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
         grocer_lx0(grocer_i)=null()
      elseif varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         grocer_lx0(grocer_i)=null()
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif str5 ~= 'maxit'...
      & str4 ~= 'btol'...
      & str4 ~= 'hess'...
      & str4 ~= 'ftol'...
      & str4 ~= 'gtol'...
      & str6 ~= 'dirtol'...
      & str4 ~= 'cond'...
      & str6 ~= 'lambda'...
      & str5 ~= 'delta'...
      & str6 ~= 'optprt' ...
      then
         varargin(grocer_i)=null()
      else
         grocer_lx0(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
lx0_l=length(grocer_lx0)
grocer_lx=list(grocer_lx0(lx0_l))
for i=2:lx0_l
   grocer_lx($+1)=grocer_lx0(lx0_l-i+1)
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
  explouniv(grocer_namey0,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
nobs2=size(grocer_y,1)
[nobs,nvar] = size(grocer_x);
if nvar >= nobs then
   error('too many exogenous variables')
end
 
// transformation of the names into variables
if nobs~=nobs2 then
  error('exogenous and endogenous variables must have the same # obs');
end
 
// find # of censored observations
select grocer_trunc
case 'left' then
   nobsc=max(size(matrix(find(grocer_y>grocer_vtrunc),1,-1)))
case 'right' then
   nobsc=max(size(matrix(find(grocer_y<=grocer_vtrunc),1,-1)))
else
   error('trunc should be set to left or right')
end
 
if ~exists('b0','local') then
  // use ols starting values
  res = ols1(grocer_y,grocer_x);
  b = res('beta');
  sige = res('sige');
  b0 = [b;sige];
end
 
 
// maximize the likelihood function
select grocer_trunc
case 'left' then
  // case of left-truncation
   oresult = maxlik(to_llike,b0,grocer_y,grocer_x,grocer_vtrunc,varargin(:))
case 'right' then
   oresult = maxlik(to_rlike,b0,grocer_y,grocer_x,grocer_vtrunc,varargin(:))
end
 
iter = oresult('iter');
llf = -oresult('f');
vcov = inv(oresult('hess'));
grad = oresult('g');
bet = oresult('b');
 
if iter==oresult('infoz')('maxit') then
   warning('no convergence in tobit in '+string(iter)+' iterations');
end
 
// now compute inference results
 
bhat = bet(1:nvar,1);
sig = bet(nvar+1,1);
 
vcov = vcov(1:nvar,1:nvar);
stdb = sqrt(diag(vcov));
tstat = bhat ./ stdb;
yhat = grocer_x*bhat;
resid = grocer_y-yhat;
sigu = resid'*resid;
 
ym = grocer_y-mean0(grocer_y);
rsqr1 = sigu/(nobs-nvar);
rsqr2 = ym'*ym;
rsqr=1-rsqr1/rsqr2
// r-squared
rsqr1 = rsqr1/(nobs-nvar);
rsqr2 = rsqr2/(nobs-1);
rbar=1-rsqr1/rsqr2
// rbar-squared
 
ediff = resid(2:nobs)-resid(1:nobs-1)
dw = ediff'*ediff/sigu
// durbin-watson
 
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
condindex=bkwols(grocer_x)
 
rtobit=tlist(['results';'meth';'y';'x';'nobs';'nobsc';...
'nvar';'beta';'yhat';'resid';'vcovar';'sige';'sigu';'ser';...
'tstat';'pvalue';'dw';'condindex';'prescte';'iter';'lik';...
'opthess';'grad'],...
'tobit',grocer_y,grocer_x,nobs,nobsc,nvar,bhat,yhat,resid,vcov,sig,sigu,...
sqrt(sigu/(nobs-nvar)),tstat,pvalue,dw,condindex,%f,iter,...
llf,oresult('meth'),grad)
 
rtobit(1)($+1) = 'prests'
rtobit(1)($+1) = 'namex'
rtobit(1)($+1) = 'namey'
rtobit(1)($+1) = 'dropna'
rtobit('prests')=grocer_prests
rtobit('namex')=grocer_namexos
rtobit('namey')=grocer_namey
rtobit('dropna')=grocer_dropna
 
if grocer_prests then
   rtobit(1)($+1) = 'bounds'
   rtobit('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rtobit(1)($+1)='nonna'
   rtobit('nonna')=nonna
end
 
if grocer_prt then
   prt_ols(rtobit,%io(2))
end
endfunction
