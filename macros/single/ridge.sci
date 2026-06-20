function [rridge]=ridge(grocer_namey0,varargin)
 
// PURPOSE: computes Hoerl-Kennard Ridge Regression
// ------------------------------------------------------------
// REFERENCES: David Birkes, Yadolah Dodge, 1993, "Alternative
// Methods of Regression" and Hoerl, Kennard, Baldwin, 1975
// "Ridge Regression: Some Simulations', Communications in
// Statistics
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
//   . the string 'theta=xx' if the user wants to enter theta's
//     value (default is the one recommended by Hoerl and
//     Kennard)
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rridge = a tlist with
//   . rridge('meth')  = 'ridge'
//   . rridge('y')     = y data vector
//   . rridge('x')     = x data matrix
//   . rridge('nobs')  = nobs
//   . rridge('nvar')  = nvars
//   . rridge('beta')  = bhat
//   . rridge('yhat')  = yhat
//   . rridge('resid') = residuals
//   . rridge('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rridge('sige')  = estimated variance of the residuals
//   . rridge('sige')  = estimated variance of the residuals
//   . rridge('ser')  = standard error of the regression
//   . rridge('tstat') = t-stats
//   . rridge('pvalue') = pvalue of the betas
//   . rridge('dw')    = Durbin-Watson Statistic
//   . rridge('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rridge('theta') = the scale factor theta
//   . rridge('rsqr')  = rsquared
//   . rridge('rbar')  = rbar-squared
//   . rridge('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rridge('pvaluef') = its significance level
//   . rridge('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rridge('namey') = name of the y variable
//   . rridge('namex') = name of the x variables
//   . rridge('dropna') = boolean indicating if NAs had
//		   been droped
//   . rridge('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rridge('nonna') = vector indicating position of non-NAs
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
 
grocer_prt=%t
grocer_dropna=%f
grocer_theta=[]
grocer_nargin=length(varargin)
 
// separate from the list of variable arguments the list of
// exogenous variables and other arguments
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      if varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i) = null()
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
 
      if part(varargin(grocer_i),1:5) == 'theta'  then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i) = null()
      end
   end
end
 
grocer_lx=varargin
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
      explouniv(grocer_namey0,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
rridge=ridge1(grocer_y,grocer_x,grocer_theta)
// saves the names, the bounds if the regression involves ts
rridge(1)($+1) = 'prests'
rridge(1)($+1) = 'namex'
rridge(1)($+1) = 'namey'
rridge(1)($+1) = 'dropna'
rridge('prests')=grocer_prests
rridge('namex')=grocer_namexos
rridge('namey')=grocer_namey
rridge('dropna')=grocer_dropna
if grocer_prests then
   rridge(1)($+1) = 'bounds'
   rridge('bounds')=grocer_boundsvarb
end
if grocer_dropna then
   rridge(1)($+1)='nonna'
   rridge('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rridge,foutput)
   prt_ols(rridge,%io(2))
   pltuniv(rridge,'all')
end
 
endfunction
