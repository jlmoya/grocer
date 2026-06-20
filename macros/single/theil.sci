function [results]=theil(grocer_rvec,grocer_rmat,grocer_v,grocer_namey0,varargin)
 
// PURPOSE: computes Theil-Goldberger mixed estimator
//          y = X B + E, E = N(0,sige*IN)
//          c = R B + U, U = N(0,v)
// ------------------------------------------------------------
// INPUT:
// * grocer_rvec = a vector of prior mean values, (c above)
// * grocer_rmat = a matrix of rank(r)            (R above)
// * grocer_v = prior variance-covariance      (var-cov(U) above)
// * grocer_namey0 = a time series, a real (n x 1) vector or a
// string equal to the name of a time series or a (n x 1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (n x p) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
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
//   . results('rsqr')  = rsquared
//   . results('rbar')  = rbar-squared
//   . results('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . results('pvaluef') = its significance level
//   . results('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . results('namey') = name of the y variable
//   . results('namex') = name of the x variables
//   . results('pmean') = prior means
//   . results('pstd')  = prior std deviations
//   . results('dropna') = boolean indicating if NAs have
//     been dropped
//   . results('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . results('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2019
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
grocer_dropna=%f
grocer_prt=%t
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
grocer_lx=varargin
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
    explouniv(grocer_namey0,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
results=theil1(grocer_y,grocer_x,grocer_rvec,grocer_rmat,grocer_v)
 
results(1)=[results(1);'prests';'namey';'namex';'pmean';'pstd';'dropna']
results('prests')=grocer_prests
results('namey')=grocer_namey
results('namex')=grocer_namexos
results('pmean')=grocer_rvec
results('pstd')=sqrt(diag(grocer_v))
results('dropna')=grocer_dropna
 
if grocer_prests then
   results(1)($+1) = 'bounds'
   results('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   results(1)($+1)='nonna'
   results('nonna')=nonna
end
 
if grocer_prt then
   prt_theil(results,%io(2))
   pltuniv(results,'all')
end
 
endfunction
