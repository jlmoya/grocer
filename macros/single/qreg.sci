function res = qreg(grocer_namey,grocer_tau,varargin);
 
// PURPOSE: perform quantile regression
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * grocer_tau = a (q x 1) vector, the values of the quantiles
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . 'dropna' if the user wants to remove the NA values
//     from the data
//   . 'algo=xxx' where xxs is the alogrithm used to find
//     the solution ('linpro' or 'qreg_solvlp1')
//   . 'weight=xxx' where xxs is a vector of the same size as
//     the endogenous variable, if the user wants to weight
//     differently the observations (default: equal weights)
//   . 'maxit=xxx' where xxx is the maximum number of iterations
//     allowed (default: none)
//   . 'sigma=xxx' where xxx is a scalar, < 1, the scaling
//     factor determines how close the corrector step is allowed
//     to come to the boundary of the constraint set in the
//     interior point method
//   . 'eps=xxx' where xxx is the tolerance value for
//     convergence (default: sqrt(%eps))
//   . 'big=xxx' where xxx is the number used to remove the
//     residuals of the wrong sign (default: 1E20)
// ------------------------------------------------------------
// OUTPUT:
// res = a resesults tlist with:
// - res('meth') = 'quantile'
// - res('y') = y data vector
// - res('x') = x data matrix
// - res('tau') = vector of quantiles to be estimated
// - res('weights') = 0 or a (nobs x 1) vector of observations
//      weights
// - res('nobs')  = # observations
// - res('nvar')  = # variables
// - res('beta')  = (nvar x q) matrix of quantile estimations
// - res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - res('namey') = name of the y variable
// - res('namex') = name of the x variables
// - res('dropna') = boolean indicating if NAs have
//		   been dropped
// - res('bounds') = if there is a time series in the
//     regression, the bounds of the regression
// - res('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_weight = 0
// if toolbox quapro has been loaded then choose linpro as default
// algorithm; else _qreg_solvelp1
if exists('quapro') then
   grocer_algo='linpro'
else
   warning('we recommend you to install the quapro toolbox to run qreg')
   grocer_algo = 'qreg_solve'
end
 
grocer_prt=%t
grocer_dropna=%f
grocer_maxit =%inf;
grocer_eps = sqrt(%eps);
grocer_big = 1e20;
grocer_sigma = 0.99995;
 
grocer_nargin=length(varargin)
for grocer_i = grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i) = null()
 
      elseif part(grocer_argi,1:7) == 'weight=' | ...
             part(grocer_argi,1:6) == 'maxit=' | ...
             part(grocer_argi,1:6) == 'sigma=' | ...
             part(grocer_argi,1:4) == 'eps=' | ...
             part(grocer_argi,1:4) == 'big=' | ...
             part(grocer_argi,1:5) == 'algo=' then
 
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i) = null()
 
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
[y,namey,x,namexos,prests,boundsvarb,nonna]=...
    explouniv(grocer_namey,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
res=qreg1(y,x,grocer_tau,grocer_weight,grocer_algo,grocer_maxit,grocer_eps,grocer_big,grocer_sigma)
 
res(1)($+1) = 'prests'
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
res(1)($+1) = 'dropna'
res('prests')=prests
res('namex')=namexos
res('namey')=namey
res('dropna')=grocer_dropna
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=boundsvarb
end
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
 
if grocer_prt then
   prtquant(res)
end
 
endfunction;
