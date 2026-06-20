function res = IPS(varargin)
 
// PURPOSE: Im, Pesaran and Shin (2003) test of unit root
// "Testing for Unit Root in Heterogeneous Panels", Journal
// of Econometrics, 115, p. 53-74
// ------------------------------------------------------------
// INPUT:
// varargin = arguments that can be:
// * a panel data tlist (in that case there must be an argument
//   'namevar=xxx' to indicate the name of the variable in the
//    panel, see below)
// * the strings:
//   - 'pmax=x' with x=%nan or a number if for the maximal # of
//   lags for the ADF test
//   - 't_order=x' for the trend order:
//      -1: no constant, no trend
//       0: a constant, no trend (default)
//       1: a constant and a trend
//   - 'noprint' if the user does not want to print the
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
// -------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// - res('meth') = 'IPS'
// - res('y') = (T x k) matrix of data
// - res('t_order') = the trend order (-1, 0 or 1)
// - res('tbar') = Mean of Individual Augmented Dickey
//   Fuller statistics
// - res('Wbar') = Standardized IPS statistic based on
//   E[ti(pi,0)/bi=0] and V[ti(pi,0)/bi=0]
// - res('Wbar_pvalue') = Pvalue of Wbar
// - res('Zbar') = Standardized IPS statistic based on the
//   moments of the DF distribution
// - res('Zbar_pvalue') = Pvalue of Zbar
// - res('critical') = Critical Values of the Normal
//   distribution at 1%, 5% and 10%
// - res('tbar_DF') = Mean of Individual Dickey Fuller statistics
// - res('Zbar_DF') = Standardized IPS statistic
//   (assumption of no autocorrelation of residuals)
// - res('Zbar_DF_pvalue') = Pvalue of Zbar_DF
// - res('pi') = Individual lag order in individual ADF t_orders
// - res('pmax') = Maximum of lag order in individual ADF t_orders
// - res('Ti') = Adjusted Individual Size
// - res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - res('namey') = name of the y variable
// - res('dropna') = boolean indicating if NAs have
//	   been dropped
// - res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// - res('nonna') = vector indicating position of non-NAs
// -------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
// explode the arguments into the data, parameters and various
// objects
[Y,namey,prests,b,noprt,dropna,nonna,param]=explo_panelunitr(varargin(:))
 
// performs the estimation and stores the corresponding results
res = IPS1(Y,param.t_order,param.pmax,param.signif)
 
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
