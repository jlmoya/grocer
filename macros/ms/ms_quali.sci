function res=ms_quali(grocer_coding,grocer_nbqua,grocer_nblatent,varargin)
 
// PURPOSE: estimate a ms turning point model
// ------------------------------------------------------------
// INPUT:
// * coding = the way variables will be coded:
//            - 'KERN' = by quantiles estimated by the
//              Epanechnikov kernel method
//            - 'no' (or anything different from 'KERN') = raw
//               data
// * grocer_nbqua = a (2 x 1 ) vector:
//           - nbqua(1) = # of quantiles used to divide the data
//           - nbqua(2) = useless (for the moment...)
// * grocer_nblatent = # of latent variables (1 or 2)
// * varargin = arguments which can be:
//   - a time series
//   - a real (nxp) vector
//   - a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   - the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   - 'dropna' if the user wants to remove the NA values
//     from the data
//   - 'testna=%f' if the user does not want to test if there
//     are NA values in the series
//   - 'initparam=x' where x is a (nparam x 1) vector if the
//     user wants to feed the estimation with her own starting
//     values
//   - 'nbstates=x' where x is the # of states (compulsory if
//     there is only 1 latent variable)
//   - 'nojump' to impose that the latent variables jump only
//     to contiguous states
//   - 'optfunc=optimg' if the user wants to use the optim
//   optimisation function (default: optim)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim_ineq=opts' where opts are inquality options
//   for the parameters
//  (default = '')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// * res = a results tlist with:
//   - res('meth') = 'ms turning point'
//   - res('y') = original data
//   - res('nobs') = # of observations
//   - res('nvar') = # of variables
//   - res('coded y') = data transformed by the coding
//   - res('nb_quantiles') = # of quantiles used by the coding
//    (if the kernel method has been used)
//   - res('nb_latent') = # of latent state variable
//   - res('nb_states') = # of states
//   - res('nojump') = a boolean indicating whether the latent
//     state is allowed to jump from a state to another non
//     contiguous one
//   - res('param') = vector of estimated parameters
//   - res('std') = vector of associated standard errors
//   - res('tstat') = vector of associated Steudent stats
//   - res('llike') = log-likelihood
//   - res('grad') = gradient at the solution
//   - res('transition probabilities') = matrix of transition
//     probabilities (if there is only 1 state latent variable)
//   - res('transition probabilities') = matrix of transition
//     probabilities (if there is only 1 state latent variable)
//   - res('first transition probabilities') = matrix of
//     transition probabilities for the first latent variable
//     (if there are 2 state latent variables)
//   - res('first transition probabilities') = matrix of
//     transition probabilities for the second latent variable
//     (if there are 2 state latent variables)
//   - res('conditional probabilities') = matrix of conditional
//     probabilities (if there is only 1 state latent variable)
//   - res('filtered probabilities') = matrix of filtered state
//     probabilities
//   - res('smoothed probabilities') = matrix of smoothed state
//     probabilities
//   - res('PZ_std') = matrix of standard errors for the
//     transition probabilities for the first latent variable
//   - res('PW_std') = matrix of standard errors for the
//     transition probabilities for the second latent variable
//   - res('PX_cond_std') = matrix of standard errors for the
//     latent variable
//   - res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   - res('namey') = name of the y variable
//   - res('namex') = name of the x variables
//   - res('dropna') = boolean indicating if NAs have
//		   been dropped
//   - res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   - res('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_initparam=0
grocer_nojump=%f
grocer_nbstates=2
grocer_prt=%t
grocer_testna=%t
grocer_dropna=%f
grocer_optfunc='optim'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,5000',sqrt(%eps))
grocer_hdelta=1e-5
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi2=strsubst(grocer_argi,' ','')
 
      if part(grocer_argi2,1:9) == 'nbstates=' ...
         | part(grocer_argi2,1:7) == 'testna='  ...
         | part(grocer_argi2,1:10) == 'initparam='  then
         execstr('grocer_'+grocer_argi2)
         varargin(grocer_i) =null()
      elseif grocer_argi2 == 'nojump' then
         grocer_nojump=%t
         varargin(grocer_i) =null()
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i) =null()
      elseif grocer_argi2 == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i) =null()
      elseif part(grocer_argi2,1:7) == 'hdelta=' then
         grocer_hdelta=part(grocer_argi2,8:length(grocer_argi2))
      elseif part(grocer_argi2,1:10) == 'opt_optim=' then
         grocer_opt_optim('optim ineq')=part(grocer_argi2,11:length(grocer_argi2))
         varargin(grocer_i) =null()
      end
   end
end
 
[y,namey,prests,boundsvarb,nonna]=explone(varargin,[],'endogenous',grocer_testna,grocer_dropna)
 
[res,ind]=ms_quali1(y,grocer_coding,grocer_nbqua,grocer_nblatent,grocer_initparam,grocer_nbstates,grocer_nojump,grocer_opt_optim,grocer_hdelta)
 
res(1)($+1)='namey'
res('namey')=namey
res(1)($+1)='prests'
res('prests')=prests
res(1)($+1) = 'dropna'
res('dropna')=grocer_dropna
 
if prests then
   res(1)($+1)='bounds'
   res('bounds')=boundsvarb
end
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if grocer_prt then
   prtms_quali(res)
   pltms_quali(res)
end
endfunction
