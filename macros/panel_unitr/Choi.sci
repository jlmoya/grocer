function res = Choi(varargin)
 
// PURPOSE: Levin an Lin (1992) Unit Root Tests on Panel Data
// Levin, Lin and Chu (2002), Journal of Econometrics
// ------------------------------------------------------------
// INPUT:
// varargin = arguments that can be:
// * a panel data tlist (in that case there must be an argument
//   'namevar=xxx' to indicate the name of the variable in the
//    panel, see below)
// * the strings:
//   - 'lagorders=x' with x=%nan (if the lags for the ADF test
//   are to be determined automatically) or a (N x 1) or (1 x N)
//   vector of lags for the ADF test
//   - 'pmax=x' with x=%nan or a number if for the maximal # of
//   lags for the ADF test
//   - 't_order=x' for the trend order:
//      -1: no constant, no trend
//       0: a constant, no trend (default)
//       1: a constant and a trend
//    - 'noprint' if the user does not want to print the
//      results of the test
//   - 'signif=x' with x the signifance level
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
// -  res('t_order') = the trend order (0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('Pm') = Fisher''s modified Statistic (for large
//    N) : converge toward N(0,1) under H0
// -  res('Z') = Inverse Normal Test : converge toward
//    N(0,1) under H0 when N tends to infinity
// -  res('Lstar') = Modified Logit Test (George 1977):
//    converge toward N(0,1) under H0
// -  res('Pm_critical') = Critical Values of the Fisher's
//    modified Statistic (Choi, 2001) at 1%, 5% and 10%:
//    if Pm>Ca Reject H0
// -  res('Z_critical') = Critical Values of the Inverse
//    Normal Test: at 1%, 5% and 10% : if Z<Ca Reject H0
// -  res('Lstar_critical') = Critical Values of the
//    Modified Logit Test at 1%, 5% and 10%: if Lstar<Ca
//    Reject H0
// -  res('Pm_pvalue') = Pvalue associated to the Fisher's
//    modified Statistic
// -  res('Z_pvalue') = Pvalue associated to the Inverse
//    Normal Test
// -  res('Lstar_pvalue') = Pvalue associated to the
//    Modified Logit Test
// -  res('pvalue_ADF') = Individual pvalues of individual
//    ERS statitics based on standard DF pvalues (only for
//    t_order=0)
// -  res('tstat') = Individual statistiques of ERS tests
// -  res('pi') = Individual lag order in individual ADF
//    models
// -  res('Ti') = Adjusted Individual Size
// -  res('pmax') = Maximum Lag Order for individual ADF
//    regressions
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
// uses the function Choi1 translated and adapted from a
// Matlab program by: C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
// explode the arguments into the data, parameters and various
// objects
[Y,namey,prests,b,noprt,dropna,nonna,param]=explo_panelunitr(varargin(:))
 
// performs the estimation and stores the corresponding results
res = Choi1(Y,param.t_order,param.lagorders,param.pmax,param.signif)
 
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
