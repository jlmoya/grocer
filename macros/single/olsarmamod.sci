function varargout=olsarmamod(grocer_model,grocer_tsmat,grocer_indeq,grocer_AR,grocer_MA,varargin)
 
// PURPOSE: perform the estimation of an ols model with arma
// errors for an equation in a model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an integer, the # of the equation in the model
// * grocer_AR = a (nar x 1) or (1 x nar) string or real vector
//   of parameters corresponding to the AR part of the error
//   process
//     . if AR is a real then all parameters are estimated
//     . if AR is a string then all parameters with in AR
//     with an equality (such as '=0.5') are constrained to
//     the given value (0.5 in the example)
//     . if AR is a string then it can contain inequality
//    constraints; for instance '<0.5' indicates that coeff
//    must be lower than 0.5
//     . if initown is set to %F, then the user can give any
//     value to AR; only it size matters for the estimation
//     process
// * grocer_MA = a (nmaf x 1) or (1 x nmaf) string or real
//   vector of corresponding to the AR part of the error, with
//   the same working as for AR
// * varargin = arguments which can be:
//   - the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   - 'dropna' if the user wants to remove the NA values
//     from the data
//   - 'init=own' if the user wants the function to impose
//     starting values for the parameters
//   - 'beta=xxx' to fix the starting values of the
//     coefficients of the regression if the user has given the
//     option 'init=own'
//   - 'optfunc=optim' if the user wants to use the optim
//   optimisation function (default: optimg)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with
//   . res('meth')  = 'ols with arma errors'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = # observations
//   . res('nvar')  = # variables
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sigu')  = sum of squared residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('dw')    = Durbin-Watson Statistic
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('llike') = the log-likelihood
//   . res('AR') = the estimated AR part of the residuals
//   . res('MA') = the estimated MA part of the residuals
//   . res('tAR') = the t-statistics of the AR part of the
//     residuals
//   . res('tMA') = the t-statistics of the MA part of the
//     residuals
//   . res('pvalues AR') = the p-values of the AR part of the
//     residuals
//   . res('pvalues MA') = the p-values of the MA part of the
//     residuals
//   . res('V') = the estimated variance of the innovations of
//     the residuals
//   . res('AIC') = the value of the Akaïke Critrium
//   . res('BIC') = the value of the Schwarz Critrium
//   . res('grad') = the gradient at solution
//   . res('type') = the e4 type of the model
//   . res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . res('namey') = name of the y variable
//   . res('namex') = name of the x variables
//   . res('dropna') = boolean indicating if NAs have
//     been dropped
//   . res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . res('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_dropna=%f
grocer_prt=%t
grocer_initown=%f
grocer_beta=[]
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e6,1e6'],'',',2*%eps,1000',1e-5)
grocer_save=0
varargout=list(grocer_model)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi2=strsubst(grocer_argi,' ','')
      grocer_largi2=length(grocer_argi2)
 
      if grocer_argi2 == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i) =null()
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i) =null()
      elseif part(grocer_argi2,1:5) == 'beta=' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i) =null()
      elseif grocer_argi2 == 'init=own' then
         grocer_initown=%t
         varargin(grocer_i) =null()
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
      elseif part(grocer_argi,1:4) == 'save' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      end
   end
end
 
if grocer_initown & isempty(grocer_beta) then
   error('with the option ''init=own'' you must enter starting values for beta (option ''beta=...'')')
end
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,olsarma1,grocer_save,grocer_prt,grocer_AR,grocer_MA,grocer_initown,grocer_beta,grocer_optfunc,grocer_opt_optim)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
 
