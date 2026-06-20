function [rrobust]=robust(grocer_wfunc,grocer_wparm,grocer_namey0,varargin)
 
// PURPOSE: robust regression using iteratively reweighted
//          least-squares
// ------------------------------------------------------------
// INPUT:
// * grocer_wfunc = 'huber' for Huber's t function
//           'ramsay' for Ramsay's E function
//           'andrew' for Andrew's wave function
//           'tukey' for Tukey's biweight
// * grocer_wparm = weighting function parameter
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
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
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
//   . rrobust('grocer_wparm') = grocer_wparm
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
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
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
grocer_crit=sqrt(%eps)
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
      elseif part(grocer_argi,1:4) == 'crit' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      end
   end
end
 
grocer_lx=varargin
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
    explouniv(grocer_namey0,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
rrobust=robust1(grocer_y,grocer_x,grocer_wfunc,grocer_wparm,grocer_crit)
// saves the names, the bounds if the regression involves ts
rrobust(1)($+1) = 'prests'
rrobust(1)($+1) = 'namex'
rrobust(1)($+1) = 'namey'
rrobust(1)($+1) = 'dropna'
rrobust('prests')=grocer_prests
rrobust('namex')=grocer_namexos
rrobust('namey')=grocer_namey
rrobust('dropna')=grocer_dropna
if grocer_prests then
   rrobust(1)($+1) = 'bounds'
   rrobust('bounds')=grocer_boundsvarb
end
if grocer_dropna then
   rrobust(1)($+1)='nonna'
   rrobust('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously defined:
// prtuniv(rrobust,foutput)
   prt_ols(rrobust,%io(2))
   pltuniv(rrobust,'all')
end
endfunction
