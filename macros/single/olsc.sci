function [rolsc]=olsc(grocer_namey0,varargin)
 
// PURPOSE: compute Cochrane-Orcutt ols Regression for AR1
// errors
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (n x 1) vector
//   . a string equal to the name of a time series or a
//     (n x 1) real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'maxit=n' where n is the maximum number of
//     iterations that can be performed (default = 100)
//   . the string 'crit=n' where crit is the convergence
//     criterion, used to assess if the difference between
//     successive values of the autocorrelation coefficient is
//     significant (default=sqrt(%eps))
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rolsc = a tlist with
//   . rolsc('meth')  = 'Cochrane-Orcutt'
//   . rolsc('y')     = y data vector
//   . rolsc('x')     = x data matrix
//   . rolsc('nobs')  = # observations
//   . rolsc('nvar')  = # variables
//   . rolsc('beta')  = bhat
//   . rolsc('yhat')  = yhat
//   . rolsc('resid') = residuals
//   . rolsc('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolsc('sige')  = estimated variance of the residuals
//   . rolsc('sigu')  = sum of squared residuals
//   . rolsc('ser')  = standard error of the regression
//   . rolsc('tstat') = t-stats
//   . rolsc('pvalue') = pvalue of the betas
//   . rolsc('dw')    = Durbin-Watson Statistic
//   . rolsc('condindex') = multicolinearity cond index
//   . rolsc('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rolsc('rsqr')  = rsquared
//   . rolsc('rbar')  = rbar-squared
//   . rolsc('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rolsc('pvaluef') = its significance level
//   . rolsc('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rolsc('namey') = name of the y variable
//   . rolsc('namex') = name of the x variables
//   . rolsc('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rolsc('rho') = the autocorrelation coefficient of the
//     residuals
//   . rolsc('trho') = its T-stat
//   . rolsc('iterout') = a (niter x 3) matrix giving for each
//     iteration the estimated rho, the convergence criterion
//     and its number
//   . rolsc('dropna') = boolean indicating if NAs had
//		        been droped
//   . rolsc('nonna') = vector indicating position of non-NAs
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
// jpl@jpl.econ.utoledo.edu
 
// set default values
grocer_prt=%t
grocer_crit=sqrt(%eps)
grocer_maxit=100
grocer_dropna=%f
 
// separate from the list of variable arguments the list of
// exogenous variables and options if any
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      if varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(varargin(grocer_i),1:4) == 'crit' |...
         part(varargin(grocer_i),1:5) == 'maxit' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' then
      error('invalid type: '+typeof(varargin(grocer_i)))
   end
end
 
grocer_lx=varargin
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
  explouniv(grocer_namey0,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
// ----- setup parameters
[nobs,nvar]=size(grocer_x)
[nobs2]=size(grocer_y,1)
if nobs~=nobs2 then
  error('x and y must have same # obs in ols2');
end
if nvar >= nobs then
   error('too many exogenous variables')
end
 
rolsc=olsc1(grocer_y,grocer_x,grocer_maxit,grocer_crit)
 
rolsc(1)($+1) = 'prests'
rolsc(1)($+1) = 'namex'
rolsc(1)($+1) = 'namey'
rolsc(1)($+1) = 'dropna'
rolsc('prests')=grocer_prests
rolsc('namex')=grocer_namexos
rolsc('namey')=grocer_namey
rolsc('dropna')=grocer_dropna
 
if grocer_prests then
   rolsc(1)($+1) = 'bounds'
   rolsc('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rolsc(1)($+1)='nonna'
   rolsc('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rols,foutput)
   prt_ar1(rolsc,%io(2))
end
 
 
endfunction
