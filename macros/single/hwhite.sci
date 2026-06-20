function [rhwhite]=hwhite(grocer_namey0,varargin)
 
// PURPOSE: computes White's adjusted heteroscedastic
// consistent Least-squares Regression
// ------------------------------------------------------------
// References: H. White 1980, Econometrica Vol. 48 pp. 818-838.
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
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rhwhite = a tlist with
//   . rhwhite('meth')  = 'White''s heteroskedasticity
//                        consistent'
//   . rhwhite('y')     = y data vector
//   . rhwhite('x')     = x data matrix
//   . rhwhite('nobs')  = nobs
//   . rhwhite('nvar')  = nvars
//   . rhwhite('beta')  = bhat
//   . rhwhite('yhat')  = yhat
//   . rhwhite('resid') = residuals
//   . rhwhite('vcovar') = estimated variance-covariance matrix
//                         of beta
//   . rhwhite('sige')  = estimated variance of the residuals
//   . rhwhite('sige')  = estimated variance of the residuals
//   . rhwhite('ser')  = standard error of the regression
//   . rhwhite('tstat') = t-stats
//   . rhwhite('pvalue') = pvalue of the betas
//   . rhwhite('dw')    = Durbin-Watson Statistic
//   . rhwhite('prescte') = boolean indicating the presence or
//                     absence of a constant in the regression
//   . rhwhite('rsqr')  = rsquared
//   . rhwhite('rbar')  = rbar-squared
//   . rhwhite('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rhwhite('pvaluef') = its significance level
//   . rhwhite('prescte') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rhwhite('namey') = name of the y variable
//   . rhwhite('namex') = name of the x variables
//   . rhwhite('bounds') = if there is a timeseries in the
//                     regression, the bounds of the regression
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
// set defaults
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
 
[y,namey,x,namexos,prests,boundsvarb,nonna]=...
explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
rhwhite=hwhite1(y,x)
 
rhwhite(1)($+1) = 'prests'
rhwhite(1)($+1) = 'namex'
rhwhite(1)($+1) = 'namey'
rhwhite(1)($+1) = 'dropna'
rhwhite('prests')=prests
rhwhite('namex')=namexos
rhwhite('namey')=namey
rhwhite('dropna')=grocer_dropna
 
if grocer_dropna then
   rhwhite(1)($+1)='nonna'
   rhwhite('nonna')=nonna
end
 
if prests then
   rhwhite(1)($+1) = 'bounds'
   rhwhite('bounds')=boundsvarb
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rhwhite,foutput)
   prt_ols(rhwhite,%io(2))
end
 
endfunction
