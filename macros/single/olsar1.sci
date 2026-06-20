function [rolsar1]=olsar1(grocer_namey0,varargin)
 
// PURPOSE: computes maximum likelihood ols regression for AR1
// errors
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   - a time series
//   - a real (nxp) vector
//   - a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   - the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   - the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
//   - 'optfunc=optimg' if the user wants to use the optim
//   optimisation function (default: optim)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim_ineq=opts' where opts are inquality options
//   for the parameters
//  (default = ',''b'',[-1+%eps ; -%inf*ones(nvar,1)]
//   ,[1-%eps ; %inf*ones(nvar,1)]')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
//---------------------------------------------------
// rolsar1 = a results tlist with
//   . rolsar1('meth')  = ' ar(1) maximum likelihood'
//   . rolsar1('y')     = y data vector
//   . rolsar1('x')     = x data matrix
//   . rolsar1('nobs')  = # observations
//   . rolsar1('nvar')  = # variables
//   . rolsar1('beta')  = bhat
//   . rolsar1('yhat')  = yhat
//   . rolsar1('resid') = residuals
//   . rolsar1('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolsar1('sige')  = estimated variance of the residuals
//   . rolsar1('sigu')  = sum of squared residuals
//   . rolsar1('ser')  = standard error of the regression
//   . rolsar1('tstat') = t-stats
//   . rolsar1('pvalue') = pvalue of the betas
//   . rolsar1('dw')    = Durbin-Watson Statistic
//   . rolsar1('condindex') = multicolinearity cond index
//   . rolsar1('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rolsar1('rsqr')  = rsquared
//   . rolsar1('rbar')  = rbar-squared
//   . rolsar1('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rolsar1('pvaluef') = its significance level
//   . rolsar1('rho') = estimated first order autocorrelation of residuals
//   . rolsar1('trho') = its Student t
//   . rolsar1('like') = log-likelihood of the regression
//   . rolsar1('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rolsar1('namey') = name of the y variable
//   . rolsar1('namex') = name of the x variables
//   . rolsar1('dropna') = boolean indicating if NAs have
//		        been dropped
//   . rolsar1('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rolsar1('nonna') = vector indicating position of non-NAs
// --------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
grocer_optim_opt=''
grocer_dropna=%f
grocer_optfunc='optim'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],',''b'',[-1+%eps ; -%inf*ones(nvar,1)],[1-%eps ; %inf*ones(nvar,1)]',',2*%eps,1000',1e-5)
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi2=strsubst(varargin(grocer_i),' ','')
      grocer_largi2=length(grocer_argi2)
      if grocer_argi2 == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:8) == 'optfunc=' then
         grocer_optfunc=part(grocer_argi2,9:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:12) == 'opt_nelmead=' then
         grocer_opt_optim('nelmead')=part(grocer_argi2,13:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:10) == 'opt_optim=' then
         grocer_opt_optim('optim')=part(grocer_argi2,11:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:15) == 'opt_optim_ineq=' then
         grocer_opt_optim('optim ineq')=part(grocer_argi2,16:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:10) == 'opt_convg=' then
         execstr('grocer_opt_optim(''convg'')='+part(grocer_argi2,11:grocer_largi2))
               varargin(grocer_i)=null()
      end
   end
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
  explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
[nobs,nvar] = size(grocer_x);
[nobs2,junk] = size(grocer_y);
 
if nobs~=nobs2 then
  error('x and y must have same # obs in olsar1');
end
if nvar >= nobs then
   error('too many exogenous variables')
end
 
rolsar1=olsar1_1(grocer_y,grocer_x,grocer_optfunc,grocer_opt_optim)
 
// saves the names, the bounds if the regression involves ts
rolsar1(1)($+1) = 'prests'
rolsar1(1)($+1) = 'namex'
rolsar1(1)($+1) = 'namey'
rolsar1(1)($+1) = 'dropna'
rolsar1('prests')=grocer_prests
rolsar1('namex')=grocer_namexos
rolsar1('namey')=grocer_namey
rolsar1('dropna')=grocer_dropna
 
if grocer_prests then
   rolsar1(1)($+1) = 'bounds'
   rolsar1('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rolsar1(1)($+1)='nonna'
   rolsar1('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
   prt_ar1(rolsar1,%io(2))
   pltuniv(rolsar1,'all')
end
 
endfunction
