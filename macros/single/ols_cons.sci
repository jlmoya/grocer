function [rols]=ols_cons(grocer_namey0,varargin)
 
// PURPOSE: perform constrained least-squares regression when
// the constraints take the form: Rb = r
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
//   . the string 'R=m' where m is the R matrix in Rb = r
//   . the string 'r=m' where m is the r matrix in Rb = r
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rols = a results tlist with
//   . rols('meth')  = 'constrained ols'
//   . rols('y')     = y data vector
//   . rols('x')     = x data matrix
//   . rols('nobs')  = # observations
//   . rols('nvar')  = # variables
//   . rols('beta')  = bhat
//   . rols('yhat')  = yhat
//   . rols('resid') = residuals
//   . rols('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rols('sige')  = estimated variance of the residuals
//   . rols('sigu')  = sum of squared residuals
//   . rols('ser')  = standard error of the regression
//   . rols('tstat') = t-stats
//   . rols('pvalue') = pvalue of the betas
//   . rols('dw')    = Durbin-Watson Statistic
//   . rols('condindex') = multicolinearity cond index
//   . rols('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rols('llike') = the log-likelihood
//   . rols('R') = the R matrix in Rb=r
//   . rols('r') = the r matrix in Rb=r
//   . rols('rsqr')  = rsquared
//   . rols('rbar')  = rbar-squared
//   . rols('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rols('pvaluef') = its significance level
//   . rols('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rols('namey') = name of the y variable
//   . rols('namex') = name of the x variables
//   . rols('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rols('like') = log-likelihood of the regression
//   . rols('dropna') = boolean indicating if NAs had
//		      been droped
//   . rols('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2007
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nargin=length(varargin)
grocer_prt=%t
grocer_dropna=%f
 
for grocer_i=grocer_nargin:-1:1
 
   grocer_st=varargin(grocer_i)
   if typeof(grocer_st) == 'string' then
      grocer_stn=strsubst(grocer_st,' ','')
      if part(grocer_stn,1:2) == 'R=' | part(grocer_stn,1:2) == 'r=' then
         execstr('grocer_'+grocer_st)
         varargin(grocer_i)=null()
      elseif grocer_stn == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_stn == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
  explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
// provides the results from the regression of the vector y
// on the vector x
rols=ols2_cons(grocer_y,grocer_x,grocer_R,grocer_r)
 
// saves the names, the bounds if the regression involves ts
rols(1)($+1) = 'prests'
rols(1)($+1) = 'namex'
rols(1)($+1) = 'namey'
rols(1)($+1) = 'dropna'
rols('prests')=grocer_prests
rols('namex')=grocer_namexos
rols('namey')=grocer_namey
rols('dropna')=grocer_dropna
 
if grocer_prests then
   rols(1)($+1) = 'bounds'
   rols('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rols(1)($+1)='nonna'
   rols('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rols,foutput)
   prt_olscons(rols,%io(2))
   pltuniv(rols,'all')
end
 
endfunction
