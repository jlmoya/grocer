function [y,res]=litterman(grocer_namey,varargin)
 
// PURPOSE: Temporal disaggregation using the Litterman method
// (high level function with vectors, matrices or ts and
// the possibilty of default parmaters)
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
//   string equal to the name of a time series or a (nx1) real
//   vector between quote, representing the low frequency data
//   that must be desaggregated
// * varargin = arguments which can be:
//   - a time series
//   - a real (nx1) vector
//   - a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   - a list of such objects
//   - the string 'divfq=n' where n is the number of high
//    frequency data points for each low frequency data points
//    (default: recoverd from the data)
//   - the string 'typemin=xxx' where xxx is the maximisation
//     method (llike -default- or wls)
//   - the string 'ta=n' where n is the aggregation type:
//      n=-1 (default) ---> sum (flow)
//      n=0 ---> average (index)
//      n=i ---> i th element (stock) ---> interpolation
//   - the string 'delta=x' where x is the increment used for
//     numerical derivation
//   - 'optfunc=optim' if the user wants to use the optim
//   optimisation function (default: optimg)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim_ineq=opts' where opts are inquality options
//   for the parameters
//  (default = ',''b'',-0.99,0.99')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res = a results tlist with:
//   - res('meth')      = 'Litterman'
//   - res('ta')        = type of disaggregation
//   - res('nobs_lf')   = nobs. of low frequency data
//   - res('nobs_hf')   = nobs. of high-frequency data
//   - res('pred')      = number of extrapolations
//   - res('s')         = frequency conversion between low and high freq.
//   - res('p')         = number of regressors (including intercept)
//   - res('y_lf')      = low frequency data
//   - res('indicator') = high frequency indicators
//   - res('y')         = high frequency estimate
//   - res('y_dt')      = high frequency estimate: standard deviation
//   - res('y_up')      = high frequency estimate: sd + sigma
//   - res('y_lo')      = high frequency estimate: sd - sigma
//   - res('resid')  = high frequency residuals
//   - res('resid_lf)   = low frequency residuals
//   - res('beta')      = estimated model parameters
//   - res('sd')        = estimated model parameters: standard deviation
//   - res('tstat')     = estimated model parameters: t ratios
//   - res('pvalue')    = pvalue of the betas
//   - res('rho')       = innovational parameter
//   - res('aic')       = Information criterion: AIC
//   - res('bic')       = Information criterion: BIC
//   - res('llike')     = Objective function used by the estimation method
//   - res('typemin')   = method of estimation
//   - res('llike')     = Log-likelihood at the estimated parameters
//   - res('sigma')     = Variance at the estimated parameters
//   - res('namey')     = Name of the low frequency aggregate
//   - res('namex')     = Name of the high frequency indicators
//   - res('prests')    = a boolean indicating the presence or
//     absence of a time series in the regression
//   - res('bounds')    = if there is a timeseries in the
//     regression, the bounds of the regression
// ------------------------------------------------------------
// REFERENCE:  Litterman, R.B. (1983) "A random walk, Markov model
// for the distribution of time series", Journal of Business and
// Economic Statistics, vol. 1, n. 2, p. 169-173.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2012
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from Matlab programs written
// by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
// set defaults
grocer_calc_divfq=%t
grocer_delta=sqrt(%eps)
grocer_typemin='llike'
grocer_ta=-1
grocer_prt=%t
grocer_optfunc='optim'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],',''b'',-0.99,0.99',',2*%eps,1000',1e-5)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi2=strsubst(grocer_argi,' ','')
      grocer_indeq=strindex(grocer_argi,'=')
      if size(grocer_indeq,2)>1 then
         error('argument should have only one ''='' sign')
      elseif size(grocer_indeq,2) == 1 then
         grocer_argi2a=strsubst(part(grocer_argi,1:grocer_indeq-1),' ','')
         grocer_argi2b=part(grocer_argi,grocer_indeq+1:length(grocer_argi))
         if grocer_argi2a == 'divfq' then
            execstr('grocer_'+grocer_argi)
            varargin(grocer_i)=null()
            grocer_calc_divfq=%f
         elseif grocer_argi2a == 'delta' then
            execstr('grocer_'+grocer_argi)
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'typemin' then
            grocer_typemin=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'ta' then
            execstr('grocer_'+grocer_argi)
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_func=' then
            grocer_optfunc=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_nelmead=' then
            grocer_opt_optim('nelmead')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_optim=' then
            grocer_opt_optim('optim')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_optim_ineq=' then
            grocer_opt_optim('optim ineq')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_convg=' then
            execstr('grocer_opt_optim(''convg'')='+grocer_argi2b)
            varargin(grocer_i)=null()
         end
      elseif grocer_argi2 == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
      typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+1))
   end
end
 
if grocer_calc_divfq then
   [Y,x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,grocer_divfq]=explo_agreg(grocer_ta,grocer_namey,varargin(:))
else
   [Y,x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,tmp_divfq]=explo_agreg(grocer_ta,grocer_namey,varargin(:))
   if grocer_divfq ~= tmp_divfq then
    warning('frequency conversion divfq ('+string(grocer_divfq)+') doesn''t macth: it has been replaced by '+string(tmp_divfq))
    grocer_divfq = tmp_divfq
   end
end
 
[y,res]=litterman1(Y,x,grocer_ta,grocer_divfq,grocer_delta,grocer_typemin,grocer_optfunc,grocer_opt_optim)
 
 
res(1)($+1)='namey'
res('namey')=grocer_namendo
res(1)($+1)='namex'
res('namex')=grocer_namexos
res(1)($+1) = 'prests'
res('prests') = grocer_prestshf
 
if grocer_prestshf then
   res(1)($+1) = 'bounds'
   res('bounds') = grocer_boundshf
   y=reshape(y,grocer_boundshf(1))
   res('y_hf')=y
   res('y_dt')=reshape(res('y_dt'),grocer_boundshf(1))
   res('y_up')=reshape(res('y_up'),grocer_boundshf(1))
   res('y_lo')=reshape(res('y_lo'),grocer_boundshf(1))
end
 
if grocer_prt then
   prtdisag(res,%io(2))
end
endfunction
