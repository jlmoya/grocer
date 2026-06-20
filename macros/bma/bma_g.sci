function rbma_g = bma_g(grocer_namey0,grocer_ndraw,varargin)
 
// PURPOSE: Compute bayesian model averaging under g-prior with
// selection of g-prior as proposed by Fernadez et alii (2001)
//-----------------------------------------------------------------
// INPUT:
//	* grocer_namey0 = dependent variable vector
//	* grocer_ndraw = # of draws to carry out
//	* varargin = a string which can be
//    . a time series
//    . a real (nxk) vector
//    . a string equal to the name of a time series or a (nxp)
//           	real vector between quotes
//    . 'burnin=xx'		: # of burn-in MCMC simulation
//    . 'g =XX'     		: value of g-prior (default = 1/max(n,k^2))
//    . 'mcmc = ''mc3''
//        or ''jump''' : type of MCMC algorithm (MC3 or reversible
//           jump) must be in quote
//    . 'nvmax = xx' : max # of variables allowed in each models
//    . the string 'noprint' if the user doesn't want to print
//                 the results of the regression
//    . the string  'dropna' if the user wants to remove the NA
//     values from the data
//-----------------------------------------------------------------
// OUTPUT:
// a tlist result:
//   . rbma_g('meth')  = 'bma g-prior'
//   . rbma_g('nmod')  = # of models visited during sampling
//   . rbma_g('beta')  = bhat averaged over all models
//   . rbma_g('mprob') = posterior prob of each model
//   . rbma_g('vprob') = posterior prob of each variable
//   . rbma_g('model') = indicator variables for each model (nmod x k)
//   . rbma_g('yhat')  = yhat averaged over all models
//   . rbma_g('resid') = residuals based on yhat averaged over models
//   . rbma_g('sige')  = averaged over all models
//   . rbma_g('nobs')  = nobs
//   . rbma_g('nvar')  = # of exogenous
//   . rbma_g('y')     = y data vector
//   . rbma_g('x')     = y data vector
//   . rbma_g('visit') = visits to each model during sampling (nmod x 1)
//   . rbma_g('time')  = time taken for MCMC sampling
//   . rbma_g('ndraw') = # of MCMC sampling draws
//			 rbma_g('burnin') = # of burn-in MCMC simulation
//   . rbma_g('gprior') = value of g-prior
//   . rbma_g('bounds') = if there is a timeseries in the regression,
//     the bounds of the regression
//   . rbma_g('mcmc') = type of MCMC algorithm
//   . rbma_g('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rbma_g('namey') = name of the y variable
//   . rbma_g('namex') = name of the x variables
//   . rbma_g('bounds') = if there is a time series in the
//     regression, the bounds of the regression
//   . rbma_g('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rbma_g('nonna') = vector indicating position of non-NAs
//--------------------------------------------------------------
// REFERENCES:
// . Fernandez,Carmen, Eduardo Ley, and Mark F. J. Steel, (2001a)
//    "Model uncertainty in cross-country growth regressions",
//    Journal of Applied Econometrics}, Volume 16, number 5, pp. 563 - 576.
//
// . Fernandez,Carmen, Eduardo Ley, and Mark F. J. Steel, (2001b)
//    "Benchmark priors for bayesian model averaging",
//    Journal of Econometrics, Volume 100, number 2, pp. 381-427.
//--------------------------------------------------------------
//
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_nu = 0
grocer_d0 = 0
grocer_g  = 0
grocer_nvmax =0
grocer_burnin =0
grocer_mcmc = 'mc3'
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      str1=part(grocer_argi,1:1)
		  str4=part(grocer_argi,1:4)
      str5=part(grocer_argi,1:5)
      str6=part(grocer_argi,1:6)
      if str6 == 'burnin' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif str5 == 'nvmax' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
			elseif str4 == 'mcmc' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif str1 == 'g' then
				execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
 				grocer_dicho = %t
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif grocer_argi == 'noprint' then
         varargin(grocer_i)=null()
         grocer_prt=%f
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
if grocer_ndraw == 0 then
	error('must specify the number of MCMC sampling draws')
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
// error checking
[nx,k] = size(grocer_x)
n = size(grocer_y,1)
if nx ~= n then
	error("bma_g : y and x1 need same # of observations")
end
 
// if no vmax is specified
if grocer_nvmax == 0 then
	grocer_nvmax = k
end
 
// if no g-prior is specified
if grocer_g == 0 then
	grocer_g = 1/max(grocer_nvmax,k^2)
end
 
// MCMC algorithm
if grocer_mcmc == 'mc3' then
	grocer_tmcmc = mc3_g
else
	grocer_tmcmc = jump_g
end
 
// provides the results from the regression of the vector y
// on the vector x
rbma_g = bma_g1(grocer_y,grocer_x,grocer_ndraw,grocer_burnin,grocer_tmcmc,grocer_g,grocer_nvmax)
 
// saves the names, the bounds if the regression involves ts
rbma_g(1)($+1) = 'prests'
rbma_g(1)($+1) = 'namex'
rbma_g(1)($+1) = 'namey'
rbma_g(1)($+1) = 'mcmc'
rbma_g(1)($+1) = 'dropna'
rbma_g('prests')=grocer_prests
rbma_g('namex')=[grocer_namexos ; 'const']
rbma_g('namey')=grocer_namey
rbma_g('mcmc')=grocer_mcmc
rbma_g('dropna')=grocer_dropna
 
if grocer_prests then
   rbma_g(1)($+1) = 'bounds'
   rbma_g('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rbma_g(1)($+1)='nonna'
   rbma_g('nonna')=grocer_nonna
end
 
if grocer_prt then
	prtbma_g(rbma_g,%io(2))						
	pltuniv(rbma_g,'all')
	pltdensbma_g(rbma_g)
end
 
endfunction
