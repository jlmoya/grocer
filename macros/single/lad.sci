function [rlad]=lad(grocer_namey0,varargin)
 
// PURPOSE: performs least absolute deviations regression
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
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'itmax=n' where n is the maximum # of
//     iterations (for example 'itmax=10'; default=500)
//   . the string 'crit=n' where n is the convergence
//     criterion (for example 'crit=1e-5'; default = 1e-15)
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rlad = a tlist with
//   . rlad('meth')  = 'lad'
//   . rlad('y')     = y data vector
//   . rlad('x')     = x data matrix
//   . rlad('nobs')  = nobs
//   . rlad('nvar')  = nvars
//   . rlad('b_new')  = bhat
//   . rlad('yhat')  = yhat
//   . rlad('resid') = residuals
//   . rlad('vcovar') = estimated variance-covariance matrix of
//     b_new
//   . rlad('sige')  = estimated variance of the residuals
//   . rlad('sige')  = estimated variance of the residuals
//   . rlad('ser')  = standard error of the regression
//   . rlad('tstat') = t-stats
//   . rlad('pvalue') = pvalue of the b_news
//   . rlad('dw')    = Durbin-Watson Statistic
//   . rlad('condindex') = multicolinearity cond index
//   . rlad('prescte') = boolean indicating if the R² can be
//     calculated
//   . rlad('iter')  = # of iterations
//   . rlad('conv')  = convergence max(abs(bnew-bold))
//   . rlad('weight')  = weight used to do the last ols
//                           regression
//   . rlad('namey') = name of the y variable
//   . rlad('namex') = name of the x variables
//   . rlad('dropna') = boolean indicating if NAs had
//		                         been droped
//   . rlad('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rlad('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// NOTES: minimizes sum(abs(y - x*b)) using re-iterated
//        weighted least-squares where the weights are the
//       inverse of the absolute values of the residuals
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
// Adapated from:
// Ron Schoenberg rons@u.washington.edu
// Date: May 29, 1995 and first
// converted from Gauss code to MATLAB by:
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
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nona]=...
      explouniv(grocer_namey0,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
rlad=lad1(grocer_y,grocer_x,grocer_crit,grocer_maxit)
 
// saves the names, the bounds if the regression involves ts
rlad(1)($+1) = 'prests'
rlad(1)($+1) = 'namex'
rlad(1)($+1) = 'namey'
rlad(1)($+1) = 'dropna'
rlad('prests')=grocer_prests
rlad('namex')=grocer_namexos
rlad('namey')=grocer_namey
rlad('dropna')=grocer_dropna
if grocer_prests then
   rlad(1)($+1) = 'bounds'
   rlad('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rlad(1)($+1)='nonna'
   rlad('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rlad,foutput)
   prt_ols(rlad,%io(2))
end
 
endfunction
