function [rsur]=sur(varargin)
 
// PURPOSE: provide Zellner Seemingly Unrelated Regression
// ------------------------------------------------------------
// INPUT:
// strings which can be:
// * 'noprint' if the user does not want to print the results
// * 'niter=x' where x is the max # iterations authorized
//   (optional; default =100)
// * 'crit=x' where x is the convergence criterion
//   (optional; default =1e-4)
// * 'coef=xx' where xx is a vector of coefficients names
// * equations written 'vary=coef1*varx1+...+coefi*varxi'
//   where:
//   - coefi = the name of a coefficient
//   - varxi = the name of a variable
// * 'unequal' if the equations do not all cover the
// entered the time span given by the bounds (so, the user must
// have bounds by the use of the function bounds) and the user
// wants to estimate all equations over the largest time span
// included in the one covered by the bounds
// * 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// rsur = a tlist with
// - rsur('meth') = 'sur'
// - rsur('y') = a (nobs x neqs) matrix of endogenous variables
// - rsur('x') = a (nobs*neqs x nvar) matrix of exogenous variables
// - rsur('nobs') = # of observations
// - rsur('neqs') = # of estimated equations
// - rsur('ncoef') = # of estimated coefficients
// * rsur('nvar') = a (neqs x 1) vector collecting the # of
//   exogenous variables in each equations
// - rsur('beta') = bhat
// - rsur('yhat') = a (nobs x neqs) matrix of adjusted y
// - rsur('tstat') = t-stats
// - rsur('pvalue') = pvalue of the betas
// - rsur('resid') = a (nobs*neqs x nvar) matrix of estimated
//   residuals
// - rsur('sigma') = covariance matrix of the residuals
// - rsur('vcovar') = covariance matrix of the estimated coeffs
// - rsur('corr') = correlation matrix of the residuals
// - rsur('sigu') = (1 x neqs) sum of squared residuals
// * rsur('ser') = (neqs x 1) matrix of standard errors of the
//   regression
// - rsur('dw') = (1 x neqs) Durbin-Watson
// - rsur('llike') = log-likelihood of the estimated model
// - rsur('aic') = Akaïke information criterion
// - rsur('bic') = Schwartz information criterion
// - rsur('hq') = Hannan-Quinn information criterion
// * rsur('condindex') = a (1 x neqs) vector collecting the
//   condition index of each equation
// - rsur('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - rsur('dropna') = boolean indicating if NAs have
//     been dropped
// - rsur('namecoef') = (ncoef x 1) mame of the coeffcients
// - rsur('namey') = name of endogenous variables
// - rsur('eqs') = list of the neqs equations
// - rsur('coefs') = list of the coefs names in each equation
// - rsur('bounds') = if any, the bounds of the equations:
//   * a string vector if the bounds are common to all
//   equations (option 'unequal' not given)
//   * a list of string vectors if the bounds are specific to
//   each equation (option 'unequal' given)
// - rsur('dropna') = boolean indicating if NAs have been dropped
// - rsur('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// NOTES:
// * some coefficients can be common to several equations
// * there can be spaces in the text of the equations
// * if you want to introduce a constant in your equation, you
//   can omit the '*varxi' in the text of the equation
// * the exogenous variable can be expressed anyway
// * the only constraint is that the model must be linear in
//   its coefficients
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_neqs=length(varargin)
 
// set defaults
grocer_itmax=100
grocer_crit=1e-4
grocer_defcoef=%f
grocer_prt=%t
grocer_unequal=%f
grocer_dropna=%f
 
// find if the user has given options, store them and keep the
// equations in the varargin list
for grocer_i=grocer_neqs:-1:1
   grocer_eq=varargin(grocer_i)
   if grocer_eq == 'noprint' then
      grocer_prt=%f
      varargin(grocer_i)=null()
   elseif grocer_eq == 'unequal' then
      grocer_unequal=%t
      varargin(grocer_i)=null()
   elseif grocer_eq == 'dropna' then
      grocer_dropna=%t
      varargin(grocer_i)=null()
   else
      grocer_indequal=strindex(varargin(grocer_i),'=')
      if size(grocer_indequal,2) ~= 1 then
         error('bad expression for',varargin(grocer_i))
      end
      if (part(varargin(grocer_i),1:6) == 'itmax='...
         | (part(varargin(grocer_i),1:5) == 'crit=')) then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
         grocer_neqs=grocer_neqs-1
      else
         if part(varargin(grocer_i),1:9) == 'namecoef=' then
            grocer_namecoef=str2vec(varargin(grocer_i),',')
            grocer_ncoef=size(grocer_namecoef,1)
            grocer_defcoef=%t
            varargin(grocer_i)=null()
         end
      end
   end
end
 
grocer_neqs=length(varargin)
// if the user has not provided the names of the coefficients
// determine them
grocer_speccarb=['=' ; '+' ; '(' ; '-' ; '*']
grocer_speccara=['+' ; '-' ; '*' ; '/' ; ')']
if ~grocer_defcoef then
   grocer_namecoef=defaultcoef('a',grocer_speccarb,grocer_speccara,varargin(:))
end
 
if grocer_unequal then
   rsur=suruneq(grocer_namecoef,grocer_speccara,grocer_speccarb,grocer_crit,grocer_dropna,varargin(:))
else
   rsur=surregu(grocer_namecoef,grocer_speccara,grocer_speccarb,grocer_crit,grocer_dropna,varargin(:))
end
 
if grocer_prt then
   prtsys(rsur)
end
 
endfunction
