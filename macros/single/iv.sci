function [riv]=iv(grocer_namey0,varargin)
 
// PURPOSE: compute instrumental variables estimation for a
// single equation
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = dependent variable vector (nobs x 1)
// * varargin is either
//   - the string 'exo=[var1;var2;...,vark]' where var1, var2,
//   ... , vark are exogenous variables which are therefore not
//   instrumented
//   - the string 'endo=[var1;var2;...,varl]' where var1, var2,
//   ... , varl are endogenous variables which are therefore
//   instrumented
//   - the string 'ivar=[var1;var2;...,varm]' where var1, var2,
//   ... , varm are the instruments
//  - the string 'noprint' if the user doesn't want to print
//      the results of the regression
//  - the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// results = a results tlist with
// - riv('meth')  = 'iv'
// - riv('nobs')  = nobs
// - riv('nendog') = # of endogenous variables
// - riv('nexog')  = # of exogenous variables
// - riv('nvar')   = # of endogenous + # of exogenous
// - riv('y')      = y data vector
// - riv('beta')  = bhat estimates
// - riv('tstat') = t-statistics
// - riv('pvalue') = pvalue of
// - riv('yhat')  = yhat predicted values
// - riv('resid') = residuals
// - riv('residiv') = residuals calculated with the
//   endogenous variables replaced by their regression from
//   first stage estimation
// - riv('sigu')  = e'*e
// - riv('sige')  = e'*e/(n-k)
// - riv('ser')  = standard error of the regression
// - riv('dw')    = Durbin-Watson Statistic
// - riv('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
// - riv('condindex') = multicolinearity cond index
// - riv('raux') = a list, collecting the residuals tlists
//   from 1 stage regressions
// - riv('first stage F') = the vector of F values of the first
//   stage regressions
// - riv('rsqr')  = rsquared
// - riv('rbar')  = rbar-squared
// - riv('f')    = F-stat for the nullity of coefficients
//    other than the constant
// - riv('pvaluef') = its significance level
// - riv('grsqr')  = generalized rsquared (that is which takes
//    into account the endogeneity of the variables)
// - riv('grsqr')  = generalized rsquared (that is which takes
//    into account the endogeneity of the variables)
// - riv('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - riv('namey') = name of the y variable
// - riv('namex') = name of the x variables
// - riv('nameinst') = name of the instruments
// - riv('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// - riv('dropna') = boolean indicating if NAs had
//		                         been droped
// - riv('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt=%t
grocer_dropna =%f
grocer_nargin=length(varargin)
 
for grocer_i=1:grocer_nargin
 
   grocer_st=varargin(grocer_i)
 
   if part(grocer_st,1:5) == 'endo=' then
      grocer_endo=str2vec(grocer_st)
   end
 
   if part(grocer_st,1:4) == 'exo=' then
      grocer_exo=str2vec(grocer_st)
      grocer_nx=size(grocer_exo,1)
   end
 
   if part(grocer_st,1:5) == 'ivar=' then
      grocer_ivar=str2vec(grocer_st)
      grocer_niv=size(grocer_ivar,1)
   end
 
   if grocer_st == 'noprint' then
      grocer_prt=%f
   end
 
   if grocer_st == 'dropna' then
      grocer_dropna=%t
   end
 
end
 
[grocer_mats,grocer_names,grocer_prests,grocer_b]=explon(list(grocer_namey0,grocer_endo,grocer_exo,grocer_ivar),...
['endogenous' 'rhs endogenous' 'exogenous' 'instruments'],[],%t,grocer_dropna)
 
grocer_y=grocer_mats(1)
grocer_endo=grocer_mats(2)
grocer_exo=grocer_mats(3)
grocer_ivar=grocer_mats(4)
 
 
riv=iv1(grocer_y,grocer_endo,grocer_exo,grocer_ivar)
 
// saves the names, the bounds if the regression involves ts
riv(1)($+1) = 'prests'
riv(1)($+1) = 'namex'
riv(1)($+1) = 'nameendo'
riv(1)($+1) = 'namey'
riv(1)($+1) = 'nameinst'
riv(1)($+1) = 'dropna'
riv('prests')=grocer_prests
riv('namex')=[grocer_names(2) ; grocer_names(3)]
riv('nameendo')=grocer_names(2)
riv('namey')=grocer_names(1)
riv('nameinst')=grocer_names(4)
riv('dropna') =grocer_dropna
 
if grocer_prests then
   riv(1)($+1) = 'bounds'
   riv('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   riv(1)($+1)='nonna'
   riv('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(riv,foutput)
   prt_iv(riv,%io(2))
end
endfunction
