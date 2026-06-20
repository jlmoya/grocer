function res = Moon_Perron(varargin)
 
// PURPOSE: Moon and Perron (2003) test of unit root "Testing
// for a Unit Root in Panels with Dynamic Factors",
// Journal of Econometrics, Elsevier, vol. 122(1), p. 81-126,
// September.
// ------------------------------------------------------------
// INPUT:
// varargin = arguments that can be:
// * a panel data tlist (in that case there must be an argument
//   'namevar=xxx' to indicate the name of the variable in the
//    panel, see below)
// * the strings:
//   - 'kmax=x' with x=maximum number of common factors used to
//   compute the criterion functions for the estimation of r,
//   the number of common factors. If it is not specified
//   it is set to min(N,T)
//   - 'criteria=x' with x = Criteria used to estimate the
//      number of common factors
//            = 'IC1', 'IC2', 'IC3', 'PC1', 'PC2', 'PC3',
//              'AIC3', 'BIC3'
//            (see Bai and Ng (2002))
//   - 't_order=x' for the trend order:
//      -1: no constant, no trend
//       0: a constant, no trend (default)
//       1: a constant and a trend
//   - 'bandwidth=n' with:
//       n = 'C' (Default) common lag troncature for the
//           Bartlett kernel (Levin and Lin 2003)
//       n = 'N' for the Newey West (1994)'s non parametric
//                   bandwidth parameter
//       n = 'A' for the Andrews (1991) automatic bandwidth
//           parameter selection with AR(1) structure
//    - 'kernel=n' with:
//       n = 'b' for Bartlett (Default)
//       n= 'qs' for Quadratic Spectral (not possible
//              when bandwitch = 'C')
//    - 'noprint' if the user does not want to print the
//      results of the test
//   - 'namevar=xxx' where xx is the name of the variable in
//    the panel (only if the data are in a 'panel data' tlist,
//    see help paneldb)
// * a time series
// * a real (nxp) matrix
// * a string equal to the name of a time series or a (nxp)
//     real matrix between quotes
//  (note that there must be several variables of this type to
//  be able to perform a panel unit root test)
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// -  res('meth') = 'Levin-Lin'
// -  res('y') = (T x k) matrix of data
// -  res('t_order') = the trend order (-1, 0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('ta_star') = Statistic ta_star
// -  res('tb_star') = Statistic tb_star
// -  res('ta_pvalue') = Pvalue for the statistics ta_star
// -  res('tb_pvalue') = Pvalue for the statistics tb_star
// -  res('critical') = Normal Critical Values for the
//    statistics ta_star and tb_star at 1%, 5% and 10%
// -  res('rho_pool') = Pooled OLS estimator on initial
//    series
// -  res('rho_star') = Modified pooled OLS estimator using
//    de-factored data
// -  res('khat') = Estimated numbers of Factor with IC1,
//    IC2, IC3, PC1, PC2, PC3, AIC3 and BIC3
// -  res('criteria') = Criteria used to estimate the number
//    of common factors. Default value = 1 (IC1)
// -  res('IC') = IC1, IC2 and IC3 Information criteriums
//    for r=1,..,rmax
// -  res('PC') = PC1, PC2 and PC3 Information criteriums
//    for r=1,..,rmax
// -  res('BIC3') = BIC3 Information criterium for
//    k=1,..,kmax (only BIC criteria function of N and T)
// -  res('AIC3') = AIC3 Information criterium (only AIC
//    criteria function of N and T): it tends to
//    overestimate k
// -  res('kmax') = Maximum number of common factors
//    authorized
// -  res('h') = Values of individual bandwitch parameters
// -  res('LRV') = Estimated of Individual Long Run
//    Variances
// -  res('TLRV') = Estimated of Individual Temporal Long
//    Run Variances
// -  res('kernel') = kern function used
// -  res('bandwidth') = Method to fix the bandwitch
//    parameter
// - res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - res('namey') = name of the y variable
// - res('dropna') = boolean indicating if NAs have
//	   been dropped
// - res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// - res('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// uses the function Levin_Lin1 translated and adapted from a
// Matlab program by: C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
// explode the arguments into the data, parameters and various
// objects
[Y,namey,prests,b,noprt,dropna,nonna,param]=explo_panelunitr(varargin(:))
 
// performs the estimation and stores the corresponding results
res = Moon_Perron1(Y,param.t_order,param.kmax,param.criteria,param.bandwidth,param.kernel)
 
// adds the names and various arg. to the results tlist
res(1)($+1) = 'prests'
res(1)($+1) = 'namey'
res(1)($+1) = 'dropna'
res('prests')=prests
res('namey')=namey
res('dropna')=dropna
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=b
end
 
if dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if ~noprt then
// the user has not entered 'noprint' as an argument
   prt_panelur(res,%io(2))
end
 
 
endfunction
