function [rlogit]=logit(grocer_namey0,varargin)
 
// PURPOSE: compute Logit Regression
// ------------------------------------------------------------
// References: Arturo Estrella (1998) 'A new measure of fit
// for equations with dichotomous dependent variable', JBES,
// Vol. 16, #2, April, 1998.
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'maxit=xx' if the user wants to set the
//     maximum # of iterations to xx (default=100)
//   . the string 'tol=xx' if the user wants to set the
//     convergence criterion to xx (default=1e-6)
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rlogit = a results tlist with
//   . rlogit('meth')  = 'logit'
//   . rlogit('y')     = y data vector
//   . rlogit('x')     = x data matrix
//   . rlogit('nobs')  = # observations
//   . rlogit('nvar')  = # variables
//   . rlogit('beta')  = bhat
//   . rlogit('yhat')  = yhat
//   . rlogit('resid') = residuals
//   . rlogit('vcovar') = estimated variance-covariance matrix
//     of beta
//   . rlogit('tstat') = t-stats
//   . rlogit('pvalue') = pvalue of the betas
//   . rlogit('r2mf')  =  = McFadden pseudo-R²
//   . rlogit('rsqr')  =  = Estrella R²
//   . rlogit('lratio') = LR-ratio test against intercept model
//   . rlogit('lik')    = unrestricted Likelihood
//   . rlogit('zip')    = # of 0's
//   . rlogit('one)    = # of 1's
//   . rlogit('iter')   = # of iterations
//   . rlogit('crit')   = convergence criterion
//   . rlogit('namey') = name of the y variable
//   . rlogit('namex') = name of the x variables
//   . rlogit('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rlogit('prescte') = %f (for printings)
//   . rlogit('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rlogit('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rlogit('nonna') = vector indicating position of non-NAs
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
// jpl@jpl.econ.utoledo.edu
 
grocer_dropna=%f
grocer_prt=%t
grocer_tol = .000001;
grocer_maxit = 100;
 
grocer_nargin=length(varargin)
grocer_lx=varargin
 
// separate from the list of variable arguments the list of
// exogenous variables and other arguments
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      if varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(varargin(grocer_i),1:5) == 'maxit' | ...
         part(varargin(grocer_i),1:3) == 'tol' then
         execstr('grocer_'+varargin(grocer_i))
         grocer_lx(grocer_i) = null()
      end
   end
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nona]=...
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
 
// check for all 1's or all 0's
tmp = matrix(find(grocer_y==1),1,-1);
chk = max(size(tmp));
if chk==nobs then
  error('logit: y-vector contains all ones');
elseif chk==0 then
  error('logit: y-vector contains no ones');
end
 
[t,k] = size(grocer_x);
b = ols0(grocer_y,grocer_x)
 
 
crit = 1;
cte = ones(t,1);
tmp1 = zeros(t,k);
tmp2 = zeros(t,k);
 
iter = 1;
while (iter<grocer_maxit)&(crit>grocer_tol) then
 
  tmp = cte+exp(-grocer_x*b);
  pdf = exp(-grocer_x*b) ./ (tmp .* tmp);
  cdf = cte ./ (cte+exp(-grocer_x*b));
 
  tmp = find(cdf<=0)';
  [n1,n2] = size(tmp);
  if n1~=0 then
    cdf(tmp) = .00001
  end
 
  tmp = find(cdf>=1)';
  [n1,n2] = size(tmp);
  if n1~=0 then
    cdf(tmp) = .99999
  end
 
  // gradient vector for logit
  term1 = grocer_y .* (pdf ./ cdf);
  term2 = (cte-grocer_y) .* (pdf ./ (cte-cdf));
  for kk = 1:k
    tmp1(:,kk) = term1 .* grocer_x(:,kk);
    tmp2(:,kk) = term2 .* grocer_x(:,kk);
  end
  g = tmp1-tmp2;
 
  gs = sum(g,1)';
  delta = exp(grocer_x*b) ./ (cte+exp(grocer_x*b));
  // see page 883 Green, 1997
 
  H = zeros(k,k);
  for ii = 1:t
    xp = grocer_x(ii,:)';
    H = H-delta(ii,1)*(1-delta(ii,1))*(xp*grocer_x(ii,:));
  end
 
  db = -inv(H)*gs;
  // stepsize determination
  s = 2;
  term1 = 0;
  term2 = 1;
  while term2>term1 then
    s = s/2;
 
    term1 = lo_like(b+s*db,grocer_y,grocer_x);
 
    term2 = lo_like(b+s*db/2,grocer_y,grocer_x);
  end
 
  bn = b+s*db;
  crit = abs(max(max(db,'r')));
  b = bn;
  iter = iter+1;
end
// end of while
 
// compute Hessian for inferences
delta = exp(grocer_x*b) ./ (cte+exp(grocer_x*b));
// see page 883 Green, 1997
H = zeros(k,k);
for i = 1:t
  xp = grocer_x(i,:)';
  H = H-delta(i,1)*(1-delta(i,1))*(xp*grocer_x(i,:));
end
 
// now compute regression results
covb = -inv(H);
stdb = sqrt(diag(covb));
tstat=b ./ stdb
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
 
// fitted probabilities
yhat = cte ./ (cte+exp(-grocer_x*b));
resid=grocer_y-yhat
sige=resid'*resid/t
 
// find ones
tmp = matrix(find(grocer_y==1),1,-1);
P = max(size(tmp));
cnt0 = t-P;
cnt1 = P;
// proportion of 1's
P = P/t;
// restricted likelihood
like0 = t*(P*log(P)+(1-P)*log(1-P));
 
// unrestricted Likelihood
like1 = lo_like(b,grocer_y,grocer_x);
 
// McFadden pseudo-R2
r2mf=1-abs(like1)/abs(like0)
// Estrella R2
term0 = (2/t)*like0
term1 = 1/(abs(like1)/abs(like0))^term0
rsqr=1-term1
 
// LR-ratio test against intercept model
lratio=2*(like1-like0)
 
rlogit = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'yhat';'resid';'vcovar';'tstat';'pvalue';'r2mf';...
'rsqr';'lratio';'llike';'zip';'one';'iter';'crit';'namey'...
;'namex';'prests';'prescte';'dropna';'condindex'],'logit',grocer_y,grocer_x,nobs,nvar,b,yhat...
,resid,covb,tstat,pvalue,r2mf,rsqr,lratio,like1,cnt0,cnt1,...
iter,crit,grocer_namey,grocer_namexos,grocer_prests,%f,grocer_dropna,bkwols(grocer_x))
 
if grocer_prests then
   rlogit(1)($+1) = 'bounds'
   rlogit('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rlogit(1)($+1)='nonna'
   rlogit('nonna')=nonna
end
 
if grocer_prt then
   prt_quali(rlogit,%io(2))
end
endfunction
