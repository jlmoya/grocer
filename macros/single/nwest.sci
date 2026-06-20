function [rnwest]=nwest(grocer_namey0,varargin)
 
// PURPOSE: computes Newey-West's adjusted heteroskedastic and
// autocorrelation consistent (HAC) Least-squares Regression
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time seriesor a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nx1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'win=n' where n is the length of the Barlett
//     window (default = floor(5*nobs^0.25))
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
// ------------------------------------------------------------
// OUTPUT:
// rnwest = a tlist with
//   . rnwest('meth')  = 'Newey-West''s HAC'
//   . rnwest('y')     = y data vector
//   . rnwest('x')     = x data matrix
//   . rnwest('nobs')  = nobs
//   . rnwest('nvar')  = nvars
//   . rnwest('beta')  = bhat
//   . rnwest('yhat')  = yhat
//   . rnwest('resid') = residuals
//   . rnwest('vcovar') = estimated variance-covariance matrix
//                         of beta
//   . rnwest('sige')  = estimated variance of the residuals
//   . rnwest('sigu')  = estimated variance of the residuals
//   . rnwest('ser')  = standard error of the regression
//   . rnwest('tstat') = t-stats
//   . rnwest('pvalue') = pvalue of the betas
//   . rnwest('dw')    = Durbin-Watson Statistic
//   . rnwest('condindex') = multicolinearity cond index
//   . rnwest('win') = truncation window
//   . rnwest('prescte') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rnwest('rsqr')  = rsquared
//   . rnwest('rbar')  = rbar-squared
//   . rnwest('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rnwest('pvaluef') = its significance level
//   . rnwest('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rnwest('namey') = name of the y variable
//   . rnwest('namex') = name of the x variables
//   . rnwest('bounds') = if there is a timeseries in the
//                     regression, the bounds of the regression
//   . rnwest('dropna') = boolean indicating if NAs had
//		                         been droped
//   . rnwest('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// References: W. K. Newey & K. D. West (1987)
//	"A simple, Positive Semi-Definite Positive Consistent Covariance
//	MAtrix", Econometrica, Vol. 55(3), pp. 703-708.
// ------------------------------------------------------------
// Copyright: E. Dubois & E. Michaux 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      str3=part(grocer_argi,[1:3])
      if str3 == 'win' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end 		
 
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nona]=....
          explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
if ~exists('grocer_win','local') then
   grocer_win = floor(5*size(grocer_y,1)^0.25)
end
 
rnwest=nwest1(grocer_y,grocer_x,grocer_win)
 
rnwest(1)($+1) = 'prests'
rnwest(1)($+1) = 'namex'
rnwest(1)($+1) = 'namey'
rnwest('prests')=grocer_prests
rnwest('namex')=grocer_namexos
rnwest('namey')=grocer_namey
 
if grocer_prests then
   rnwest(1)($+1) = 'bounds'
   rnwest('bounds')=grocer_boundsvarb
end
 
rnwest(1)($+1) = 'dropna'
rnwest('dropna')=grocer_dropna
if grocer_dropna then
   rnwest(1)($+1)='nonna'
   rnwest('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
 //prtuniv(rnwest,foutput)
    prt_ols(rnwest,%io(2))
    pltuniv(rnwest,'all')
end
 
endfunction
