function [res]=probit(grocer_namey0,varargin)
 
// PURPOSE: computes Probit Regression
// ------------------------------------------------------------
// References: Arturo Estrella (1998) 'A new measure of fit
// for equations with dichotmous dependent variable', JBES,
// Vol. 16, #2, April, 1998.
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
//  vector between quotes; all values should be 0 or 1
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
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
// rprobit = a results tlist with
//   . rprobit('meth')  = 'probit'
//   . rprobit('y')     = y data vector
//   . rprobit('x')     = x data matrix
//   . rprobit('nobs')  = # observations
//   . rprobit('nvar')  = # variables
//   . rprobit('beta')  = bhat
//   . rprobit('yhat')  = yhat
//   . rprobit('resid') = residuals
//   . rprobit('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rprobit('tstat') = t-stats
//   . rprobit('pvalue') = pvalue of the betas
//   . rprobit('r2mf')  =  = McFadden pseudo-R²
//   . rprobit('rsqr')  =  = Estrella R²
//   . rprobit('lratio') = LR-ratio test against intercept model
//   . rprobit('lik')    = unrestricted Likelihood
//   . rprobit('zip')    = # of 0's
//   . rprobit('one)    = # of 1's
//   . rprobit('iter')   = # of iterations
//   . rprobit('crit')   = convergence criterion
//   . rprobit('namey') = name of the y variable
//   . rprobit('namex') = name of the x variables
//   . rprobit('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rprobit('prescte') = %f (for printings)
//   . rprobit('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rprobit('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rprobit('nonna') = vector indicating position of non-NAs
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
      elseif part(varargin(grocer_i),1:3) == 'b0=' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' then
      error('invalid type: '+typeof(varargin(grocer_i)))
   end
end
 
grocer_lx=varargin
[y,namey,x,namexos,prests,boundsvarb,nonna]=explouniv(grocer_namey0,...
  grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
if exists('grocer_b0','local') then
   res=probit2(y,xgrocer_b0)
else
   res=probit2(y,x)
end
 
// saves the names, the bounds if the regression involves ts
res(1)($+1) = 'prests'
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
res(1)($+1) = 'dropna'
res('prests')=prests
res('namex')=namexos
res('namey')=namey
res('dropna')=grocer_dropna
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=boundsvarb
end
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
 
if grocer_prt then
   prt_quali(res,%io(2))
end
 
endfunction
