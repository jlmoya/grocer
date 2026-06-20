function [res]=phil_perr(grocer_namey,grocer_p,grocer_l,varargin)
 
// PURPOSE: compute Phillips-Perron test of a unit root
// hypothesis based on a Dickey-Fuller/Augmented Dickey-Fuller
// regression
// ------------------------------------------------------------
// REFERENCES:
// Phillips, Peter (1987), "Time Series Regression with a Unit
// Root", Econometrica, vol. 55, no. 2 (March), pp. 277-301
// Phillips, Peter & Pierre Perron (1988), "Testing for a Unit
// Root in Time Series Regression", Biometrika, vol. 75, no. 2
// (June), pp. 335-346
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * grocer_p = = order of time polynomial in the null-hypothesis
//   . grocer_p =  0, for constant term
//   . grocer_p =  1, for constant plus time-trend
// * grocer_l = size of the Newey-West window
// * varargin = optional arguments which can be:
//  - 'noprint' if the user doesn't want to print the results of
//     the regression
//  - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')  = 'phillips-perron'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = nobs
//   . res('nvar')  = nvars
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix
//     of beta
//   . res('sige')  = estimated variance of the residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('dw')    = Durbin-Watson Statistic
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
//   . res('dropna') = boolean indicating if NAs have
//     been droped
//   . res('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
//   . res('rho') = Phillips-perron statistic,
//                     autocorrelation/heteroskedasticity
//                     corrected value for the unit-root
//                     coefficient based on a Dickey-Fuller
//                     regression
//   . res('tstat') = Phillips-perron statistic,
//                     autocorrelation/heteroskedasticity
//                     corrected t-ratio for the unit-root
//                     coefficient based on a Dickey-Fuller
//                     regression
//   . res('p') = trend order
//   . res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . res('namey') = name of the y variable
//   . res('namex') = name of the x variables
//   . res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   .res('cv_rho_1%') = critical value at a 1% level for the
//    rho statistic
//   .res('cv_rho_5%') = critical value at a 5% level for the
//    rho statistic
//   .res('cv_rho_10%') = critical value at a 10% level for the
//    rho statistic
//   .res('cv_tstat_1%') = critical value at a 1% level for the
//    Student statistic
//   .res('cv_tstat_5%') = critical value at a 5% level for the
//    Student statistic
//   .res('cv_tstat_10%') = critical value at a 10% level for the
//    Student statistic
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
if nargin > 2 then
   [grocer_dropna,grocer_prt]=vararg2dropnaprt(varargin(:))
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
   nobs=size(y,1)
   if isempty(grocer_l) then
        grocer_l=floor(5*nobs^0.25)
   end
elseif nargin ==2 then
   grocer_dropna=%f
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
   nobs=size(y,1)
   grocer_prt=%t
   grocer_l=floor(5*nobs^0.25)
else
   error('invalid number of arguments')
end
 
x=[0 ; y(1:$-1)]
x=[x(2:nobs,1) ptrend(grocer_p,nobs-1)]
y=y(2:nobs)
 
nvar=grocer_p+2
 
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) ~= 2 then
      error('bounds are discontinous in kpss')
   end
end
 
nobs=nobs-1
if grocer_p==1 then
   x(:,3)=x(:,3)-nobs/2
end
 
res=ols2(y,x)
bet=res('beta')
ly=x(:,1)
resid=res('resid')
sigma2u=resid'*resid/nobs
sigma2=newey_west(resid,grocer_l)
h1=res('vcovar')(1,1)/res('sige')
 
rho=nobs*(bet(1,1)-1)-0.5*(sigma2-sigma2u)*h1*(nobs)^2
tstat=sqrt(sigma2u/sigma2)*(bet(1,1)-1)/sqrt(res('vcovar')(1,1))...
-0.5*(sigma2-sigma2u)/sqrt(sigma2)*nobs*sqrt(h1)
 
res('meth') = 'phillips-perron'
res(1)($+1) = 'rho'
res('rho') = rho
res(1)($+1) = 'tstat'
res('tstat') = tstat
res(1)($+1) = 'p'
res('p') = grocer_p
 
res(1)($+1) = 'prests'
res(1)($+1) = 'namey'
res('prests')=prests
res('namey')=namey
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=boundsvarb
end
 
res(1)($+1) = 'dropna'
res('dropna')=grocer_dropna
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
[crit_al,crit_t]=fuller_tab(grocer_p,nobs)
 
res(1)($+1) = 'cv_rho_1%'
res('cv_rho_1%') = crit_al(1)
res(1)($+1) = 'cv_rho_5%'
res('cv_rho_5%') = crit_al(2)
res(1)($+1) = 'cv_rho_10%'
res('cv_rho_10%') = crit_al(3)
 
res(1)($+1) = 'cv_tstat_1%'
res('cv_tstat_1%') = crit_t(1)
res(1)($+1) = 'cv_tstat_5%'
res('cv_tstat_5%') = crit_t(2)
res(1)($+1) = 'cv_tstat_10%'
res('cv_tstat_10%') = crit_t(3)
 
if grocer_prt then
   prt_phil_perr(res)
end
 
endfunction
