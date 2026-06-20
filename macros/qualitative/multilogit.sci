function res = multilogit(grocer_namey,varargin)
 
// PURPOSE: implements multinomial logistic regression
// Pr(y_i=j) = exp(x_i''bet_j)/sum_l[exp(x_i''bet_l)]
//   where:
//   i    =   1,2,...,nobs
//   j,l  = 0,1,2,...,ncat
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
//   - 'maxit=x' where x is the optional maximum number of
//     iterations (default=100)
//   - 'tol=x' where x is the optional convergence tolerance
//     (default=1e-6)
//   - 'init=v' where v is the optional vector of starting
//     values
//   - the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   - the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// res = a res tlist with:
// - res('meth') = 'multilogit'
// - res('beta') = (nvar x ncat) matrix of bet coefficients:
//                       [bet_1 bet_2 ... bet_ncat] under the
//                       normalization bet_0 = 0
// - res('coeff') = (nvar*ncat x 1) vector of beta coefficients:
//                      [beta_1 ; beta_2 ; ... ; beta_ncat] under
//                      normalization beta_0 = 0
// - res('covb') = (nvar*ncat x nvar*ncat) covariance matrix
//                       of coefficients
// - res('tstat') = (nvar*ncat x 1) vector of t-statistics
// - res('pvalue') = (nvar*ncat x 1) vector of corresponding p-values
// - res('y') = (nobs x ncat+1) matrix of data
// - res('yhat') = (nobs x ncat+1) matrix of fitted values
//                       probabilities: [P_0 P_1 ... P_ncat]
//                       where P_j = [P_1j ; P_2j ; ... ; P_nobsj]
// - res('llike') = unrestricted log likelihood
// - res('lratio') = LR test statistic against intercept-only model (all
//                       bets=0), distributed chi-squared with (nvar-1)*ncat
//                       degrees of freedom
//  - res('nobs') = number of observations
//  - res('nvar') = number of variables
//  - res('ncat') = number of categories of dependent variable
//                       (including the reference category j = 0)
//  - res('count') = vector of counts of each value taken by y, i.e.,
//                       count = [#y=0 #y=1 ... #y=ncat]
//  - res('r2mf') = McFadden pseudo-R^2
//  - res('rsqr') = Estrella pseudo-R^2
//  - res('namey') = name of the y variable
//  - res('namex') = name of the x variables
//  - res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//  - res('prescte') = %f (for printings)
//  - res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//  - res('dropna') = boolean indicating if NAs have
//		   been dropped
//  - res('nonna') = vector indicating position of non-NAs
//-------------------------------------------------------------------------
// References: Greene (1997), p.914
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt=%t
grocer_init=[]
grocer_maxit=%inf
grocer_tol=sqrt(%eps)
 
grocer_nargin=length(varargin)
 
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argis=strsubst(grocer_argi,' ','')
      if part(grocer_argis,1:5) == 'init=' | part(grocer_argis,1:6) == 'maxit=' ...
         | part(grocer_argis,1:4) == 'tol=' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
 
      elseif grocer_argis == 'noprint' then
         grocer_prt=f
         varargin(grocer_i)=null()
 
      elseif grocer_argis == 'dropna' then
         grocer_dropna=T
         varargin(grocer_i)=null()
 
      end
   end
end
 
[y,namey,x,namexos,prests,boundsvarb,nonna]=...
explouniv(grocer_namey,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
res = multilogit1(y,x,grocer_init,grocer_maxit,grocer_tol)
 
// saves the names, the bounds if the regression involves ts
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
   prt_multilogit(res,%io(2))
end
 
endfunction
