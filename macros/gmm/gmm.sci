function gmmout =gmm(grocer_namey0,gmmopt,varargin)
 
// PURPOSE: Estimate model parameters using GMM
//--------------------------------------------------------------------------
// INPUT:
// * grocer_namey0 = dependent variable vector (nobs x 1)
// * gmmopt a tlist (with 'gmm' as type) wich argument can be [default]:
//    - gmmopt('momt') = filename of moment conditions REQUIRED
//    - gmmopt('jake') = filename of Jacobian of moment cond ['numz0']
//    - gmmopt('namep') = a vector containing the name of the parameters (optional)
//    - gmmopt('gmmit') = number of GMM iterations [2]
//    - gmmopt('maxit') = cap on number of GMM iterations		[25]
//    - gmmopt('tol') = convergence criteria for iterated GMM		[sqrt(%eps)]
//    - gmmopt('W0') = Initial GMM weighting matrix			['Z']
//        'I' = identity
//        'Z' = instruments (Z'Z)
//        'C' = calculate from b
//        'Win' = fixed passed as Win
//		  'myfile' = user's own sci-file
//    - gmmopt('W') =  subsequent GMM weighting matrix ['S']
//        'S' = inverse spectral density from gmmS
//    - gmmopt('S') =  type of spectral density matrix		
//        'W'=White, 'NW'=Newey-West (Bartlett), 'G'=Gallant (Parzen)
//        'H'=Hansen (Truncated), 'AM'=Andrews-Monahan, 'P'=Plain (OLS)
//        'myfile' = user's sci-file
//    - gmmopt('aminfo') = structure if gmmopt('S')='AM' (see gmmAndMom.sci)
//    - gmmopt('lags') = lags used in truncated kernel for S	        [nobs^(1/3)]
//    - gmmopt('wtvec') = user-defined weights for Hansen matrix
//              allows for seasonals, etc (eg. wtvec = [1 0 1])
//    - gmmopt('Strim') = Contols demeaning of moments in calc of S	[1]
//         0 = none, 1 = demean e, 2 = demean Z'e
//    - gmmopt('Slast') = 1 to recalc S at final param est. 2 updates W	[1]
//    - gmmopt('null') = vector of null hypotheses for t-stats		[0]
//    - gmmopt('plt) = 1 if the user want to graph the weight of GMM matrix		[0]
//    - gmmopt('prt') = 1 if the user want to print the optimization steps [0]
// * varargin is either:
//   - the string 'exo=[var1,var2,...,varm]' where var1, var2,..., varm
//        are the exogenous variable. One should write
//        'exo=[''var1'',''var2'',...,''varm'']' to keep variables names
//   - the string 'ivar=[ivar1,ivar2,...,varm]' where ivar1, ivar2,..., ivarm
//      are the instruments (same as for exo to keep the variable names)
//   - the string 'parm0 =[p1,p2,...,pm]' where p1, p2,
//                ... , pm are the initial condition for he parameters
//   - Win user-defined initial weighting matrix OPTIONAL
//          To use a function to calculate W0, don't use Win, but set
//          gmmopt('W0') to gmmopt('U') and give the file name in gmmopt('W')
//    - 'noprint' if the user does not want to print the results
//   - 'optfunc=optimg' if the user wants to use the optim
//   optimisation function (default: optim)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim_ineq=opts' where opts are inquality options
//   for the parameters
//  (default '']
//   ,[1-%eps ; %inf*ones(nvar,1)]')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
//--------------------------------------------------------------------------
// OUTPUT: gmmout results tlist whose arguments can be:
// . gmmout('meth') = 'GMM'
// . gmmout('y') = y data vector
// . gmmout('x') = x data matrix
// . gmmout('z') = instruments data matrix
// . gmmout('f') = function value
// . gmmout('nobs') = number of observations
// . gmmout('varn') = number of parameters to estimate
// . gmmout('north') = number of orthogonality conditions
// . gmmout('neq') =  number of equations
// . gmmout('nz') =  number of instruments
// . gmmout('J') = chi-square stat for model fit
// . gmmout('pvalue fit') = p-value for model fit
// . gmmout('beta') = coefficient estimates
// . gmmout('se') = standard errors of parameters
// . gmmout('vcovar') = cov matrix of parameter estimates
// . gmmout('tstat') = t-stats for parms = null
// . gmmout('pvalue') = p-values for coefficients
// . gmmout('m') = value moments
// . gmmout('M') = value of jacobian of moments conditions
// . gmmout('mse') =  standard errors of moments
// . gmmout('varm') = covariance matrix of moments
// . gmmout('m tstat') = t-stats for moments = 0
// . gmmout('m pvalue') = p-vals for moments
// . gmmout('nz') =  number of instruments
// . gmmout('nvar') =  number of parameters
// . gmmout('df') = degrees of freedom for model
// . gmmout('null') = vector of null hypotheses for parameter values
// . gmmout('W0 type') = type of initial weighting matrix
// . gmmout('W type') = type of weighting matrix
// . gmmout('W') = weighting matrix
// . gmmout('S type') = type of spectral density matrix
// . gmmout('S') = spectral density matrix
// . gmmout('eflag') = error flag for spectral density matrix
// . gmmopt('namey') = name of "endogenous" variables
// . gmmopt('namex') = name of "exogenous" variables
// . gmmopt('namez') = name of instruments
// . gmmopt('prests') = boolean indicating presence of time series
// . gmmopt('bounds') = if there is a timeseries in the  regression, the bounds of the regression
//--------------------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
 
// set default
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,1000',1e-5)
grocer_prt=%t
grocer_dropna=%f
grocer_prt=%t
grocer_namep = []
grocer_Win= []
grocer_prt =%t;
 
out=%io(2)
if typeof(gmmopt) ~= "gmm" then // could be improved ?
  error('GMM options should be in a tlist variable')
end
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
  grocer_argi=varargin(grocer_i)
  if typeof(varargin(grocer_i)) == 'string' then
     grocer_argi2=strsubst(grocer_argi,' ','')
     str3=part(grocer_argi2,1:3)
     str4=part(grocer_argi2,1:4)
     str5=part(grocer_argi2,1:5)
     if str3 == 'exo' |str3 == 'Win' then
        execstr('grocer_'+varargin(grocer_i))
        varargin(grocer_i)=null()
     elseif str4 == 'ivar' then
        execstr('grocer_'+varargin(grocer_i))
        varargin(grocer_i)=null()
     elseif str5 == 'parm0' then
        execstr('grocer_'+varargin(grocer_i))
        varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:8) == 'optfunc=' then
         grocer_optfunc=part(grocer_argi2,9:length(grocer_argi2))
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:11) == 'opt_nelmead' then
          grocer_opt_optim('nelmead')=part(grocer_argi,13:length(grocer_argi2))
          varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:9) == 'opt_optim' then
         grocer_opt_optim('optim')=part(grocer_argi,11:length(grocer_argi2))
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:14) == 'opt_optim_ineq' then
         grocer_opt_optim('optim ineq')=part(grocer_argi,16:length(grocer_argi2))
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:9) == 'opt_convg' then
         execstr('grocer_opt_optim(''convg'')='+part(grocer_argi,11:length(grocer_argi2)))
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
 
// test presence of variable
if ~exists('grocer_exo','local') then
  error('Exogenous variable are missing')
elseif ~exists('grocer_ivar','local') then
  error('Intruments are missing')
elseif ~exists('grocer_parm0','local') then
  error('Initial condition for parameters are missing')
end
 
//[grocer_y,grocer_namey,grocer_exo,grocer_namexos,grocer_prests,grocer_boundsvarb]=...
//          explouniv(grocer_namey0,grocer_exo)
//[junk1,junk2,grocer_ivar,grocer_nameivars,grocer_prests2,grocer_boundsvarb2]=...
//          explouniv(grocer_namey0,grocer_ivar);
//
[grocer_mats,grocer_names,grocer_prests,grocer_b]=explon(list(grocer_namey0,grocer_exo,grocer_ivar),...
['endogenous' 'exogenous' 'instruments'],[],%t,grocer_dropna)
 
grocer_y=grocer_mats(1)
grocer_exo=grocer_mats(2)
grocer_ivar=grocer_mats(3)
 
grocer_namey=grocer_names(1)
grocer_namexos=grocer_names(2)
grocer_nameivars=grocer_names(3)
 
// performs GMM estimation
gmmout = gmm1(grocer_y,grocer_parm0,gmmopt,grocer_exo,grocer_ivar,grocer_Win,grocer_optfunc,grocer_opt_optim);
 
// saves the names, the bounds if the regression involves ts
gmmout(1)($+1) = 'prests'
gmmout(1)($+1) = 'namey'
gmmout(1)($+1) = 'namex'
gmmout(1)($+1) = 'nameivar'
 
gmmout('prests')=grocer_prests
gmmout('namey')=grocer_namey
gmmout('namex')=grocer_namexos
gmmout('nameivar')=grocer_nameivars
 
if grocer_prests then
   gmmout(1)($+1) = 'bounds'
   gmmout('bounds')=grocer_boundsvarb
end
 
// print results
if grocer_prt then
  prtgmm(gmmout,%io(2))
end
 
endfunction
