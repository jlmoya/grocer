function res = Chang_IV(varargin)
 
// PURPOSE: Chang (2002) unit root test "Nonlinear IV unit
// root test in panels with cross-sectional dependency",
// Journal of Econometrics, 110, 261-292n
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
//   - 'IGF=x' where IGF stands for the Instrument Generating
//     and x:
//       = 1 for F(x)=x*exp(-ci*|x|) (Default)
//         2 for F(x)=I(|x|<K) Trimmed OLS on [-K,K]
//         3 for F(x)=I(|x|<K)*x
//   - 'signif=x' with x the signifance level
//   - 'noprint' if the user does not want to print the
//     results of the test
//   - 'namevar=xxx' where xx is the name of the variable in
//   the panel (only if the data are in a 'panel data' tlist,
//   see help paneldb)
// * a time series
// * a real (nxp) matrix
// * a string equal to the name of a time series or a (nxp)
//     real matrix between quotes
//  (note that there must be several variables of this type to
//  be able to perform a panel unit root test)
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// - res('meth') = 'Chang IV'
// - res('y') = (T x k) matrix of data
// - res('t_order') = the trend order (-1, 0 or 1)
// - res('t_orderlit') = the trend order in plain english
// - res('Sn') = Average IV t-ratio statistic (distributed as
//    N(0,1) under H0)
// - res('Sn_critical') = Critical Values of normal N(0,1) at
//    1%, 5% and 10%
// - res('Sn_pvalue') = Pvalue of the average IV t-ratio
//    statistic
// - res('Zi') = Individual IV t-ratio statistics
// - res('Zi_critical') = Critical Values of normal N(0,1) at
//    1%, 5% and 10%
// - res('Zi_pvalue') = Pvalue of the individual IV t-ratio statistics
// - res('pi') = Individual lag orders
// - res('ADF') = Individual ADF statistics for comparison
// - res('AR_IV_ind') = Individual IV estimates of the autoregressive parameter
// - res('var_resIV') = Variance of Residuals of IV estimates for each unit
// - res('var_IV') = Variance of the IV estimator of the autoregressive parameter
// - res('IGF') = Instrument Generating Function used
// - res('K') = Constant K of IGF function (IGF 2 and 3 only)
// - res('ci') = Factor ci for IGF 1 : F(x)=x*exp(-ci*|x|)
// - res('prests') = boolean indicating the presence or
//   absence of a time series in the regression
// - res('namey') = name of the y variable
// - res('dropna') = boolean indicating if NAs have
//	 been dropped
// - res('bounds') = if there is a timeseries in the
//   regression, the bounds of the regression
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
res = Chang_IV1(Y,param.t_order,param.lagorders,param.pmax,param.IGF,param.signif)
 
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
