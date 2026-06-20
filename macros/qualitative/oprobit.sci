function res=oprobit(grocer_namey,varargin)
 
// PURPOSE: evaluate logit log-likelihood
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes which should be coded from 0 to  ncat,
// * varargin = optional arguments which can be:
//   - a time series
//   - a real (nxp) vector
//   - a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   - 'init=v' where v is the optional vector of starting
//     values
//   - the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   - the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
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
// res = a res tlist with:
// - res('meth') = 'ordered probit'
// - res('y') = (nobs x ncat) matrix of data
// - res('x') = (nobs x nx) matrix of data
// - res('nobs') = number of observations
// - res('nvar') = number of variables
// - res('ncat') = number of categories of dependent variable
//                       (including the reference category j = 0)
// - res('beta') = (nvar*ncat x 1) vector of beta coefficients:
//                      [beta_1 ; beta_2 ; ... ; beta_ncat] under
//                      normalization beta_0 = 0
// - res('yhat') = (nobs x ncat) matrix of fitted values
//                       probabilities: [P_0 P_1 ... P_(ncat-1)]
//                       where P_j = [P_1j ; P_2j ; ... ; P_nobsj]
// - res('r2mf') = McFadden pseudo-R^2
// - res('rsqr') = Estrella pseudo-R^2
// - res('llike') = unrestricted log likelihood
// - res('grad') = gradient vector at solution
// - res('lratio') = LR test statistic against intercept-only model (all
//                       bets=0), distributed chi-squared with (nvar-1)*ncat
//                       degrees of freedom
// - res('covb') = (nvar*ncat x nvar*ncat) covariance matrix
//                       of coefficients
// - res('tstat') = (nvar*ncat x 1) vector of t-statistics
// - res('pvalue') = (nvar*ncat x 1) vector of corresponding p-values
// - res('namey') = name of the y variable
// - res('namex') = name of the x variables
// - res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - res('dropna') = boolean indicating if NAs have
//		   been dropped
// - res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// - res('nonna') = vector indicating position of non-NAs
//-----------------------------------------------------
// Copyright: Eric Dubois 2007-2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
// set default
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,1000',1e-5)
grocer_prt=%t
grocer_dropna=%f
 
grocer_nargin=length(varargin)
 
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi2=strsubst(grocer_argi,' ','')
      grocer_largi2=length(grocer_argi2)
      if part(grocer_argi,1:5) == 'init=' then
          execstr('grocer_init'+grocer_argi2)
          varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:8) == 'optfunc=' then
         grocer_optfunc=part(grocer_argi2,10:grocer_largi2)
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
      elseif grocer_argi2 == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb]=...
explouniv(grocer_namey,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
if ~exists('grocer_init','local') then
   [nobs,nvar]=size(grocer_x)
   // find the values taken by y
   valy=unique(grocer_y)
   nvaly=size(valy,1)
//   grocer_init=ols0(grocer_y,grocer_x)
   grocer_init=zeros(nvar,1)
   p=0
   for i=1:nvaly-1
      p=p+size(find(grocer_y == valy(i)),2)/nobs
      grocer_init=[grocer_init;cdfnor("X",0,1,p,1-p)]
   end
end
 
res=oprobit1(grocer_y,grocer_x,grocer_init,grocer_optfunc,grocer_opt_optim)
// saves the names, the bounds if the regression involves ts
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
res(1)($+1) = 'dropna'
res(1)($+1) = 'prests'
res('namex')=[grocer_namexos ; 'limit point # '+string(2:nvaly)' ]
res('namey')=grocer_namey
res('prests')=grocer_prests
res('dropna')=grocer_dropna
 
if grocer_prests then
   res(1)($+1) = 'bounds'
   res('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if grocer_prt then
   prt_quali(res)
end
 
endfunction
