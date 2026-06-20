function [rolst]=olst(grocer_namey0,varargin)
 
// PURPOSE: ols with t-distributed errors
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
//  string equal to the name of a time series or a (nx1) real
//  vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (n x 1) vector
//   . a string equal to the name of a time series or a (n x 1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
//   . the string 'maxit=xx' if the user wants to set the
//     maximum # of iterations to xx (default=500)
//   . the string 'tol=xx' if the user wants to set the
//     convergence criterion to xx (default=1e-8)
// ------------------------------------------------------------
// OUTPUT:
// rolst = a tlist with
//   . rolst('meth')  = 'olst'
//   . rolst('y')     = y data vector
//   . rolst('x')     = x data matrix
//   . rolst('nobs')  = nobs
//   . rolst('nvar')  = nvars
//   . rolst('beta')  = bhat
//   . rolst('yhat')  = yhat
//   . rolst('resid') = residuals
//   . rolst('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolst('sige')  = estimated variance of the residuals
//   . rolst('ser')  = standard error of the regression
//   . rolst('tstat') = t-stats
//   . rolst('pvalue') = pvalue of the betas
//   . rolst('dw')    = Durbin-Watson Statistic
//   . rolsts('condindex') = multicolinearity cond index
//   . rolst('conv')  = convergence max(abs(bnew-bold))
//   . rolst('iter')  = # of iterations
//   . rolst('prescte') = boolean indicating if the R² can be
//     calculated
//   . rolst('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rolst('namey') = name of the y variable
//   . rolst('namex') = name of the x variables
//   . rolst('dropna') = boolean indicating if NAs had
//		   been droped
//   . rolst('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rolst('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// NOTES: uses iterated re-weighted least-squares
//        to find maximum likelihood estimates
// ------------------------------------------------------------
// REFERENCES: Section 22.3 Introduction to the Theory and
// Practice of Econometrics, Judge, Hill, Griffiths, Lutkepohl,
// Lee
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
grocer_crit = 1e-8;
grocer_maxit = 500;
grocer_prt=%t
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
 
rolst=olst1(grocer_y,grocer_x,grocer_crit,grocer_maxit)
// saves the names, the bounds if the regression involves ts
rolst(1)($+1) = 'prests'
rolst(1)($+1) = 'namex'
rolst(1)($+1) = 'namey'
rolst(1)($+1) = 'dropna'
rolst('prests')=grocer_prests
rolst('namex')=grocer_namexos
rolst('namey')=grocer_namey
rolst('dropna')=grocer_dropna
if grocer_prests then
   rolst(1)($+1) = 'bounds'
   rolst('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rolst(1)($+1)='nonna'
   rolst('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
   prt_ols(rolst,%io(2))
   pltuniv(rolst,'all')
end
endfunction
