function res = Maddala_Wu(varargin)
 
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
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// - res('meth') = 'Maddala-Wu'
// - res('y') = (T x k) matrix of data
// - res('P') = Fisher statistic based on Individual ADF
//   statistics
// - res('P_Critical') = Critical Values of the Fisher
//   statistic at 1%, 5% and 10%
// - res('P_pvalue') = Pvalue Pooled test statistic
//   (Maddala Wu 1999)
// - res('Z') = Choi (2001) statistic based on Individual ADF
//   statistics (for large N tends to N(0,1))
// - res('Z_Critical') = Critical Values of the pooled test
//   statistic (Choi, 2001) at 1%, 5% and 10%
// - res('Z_pvalue') = Pvalue Pooled test statistic
//   (Choi 2001)
// - res('ADF_pvalues') = Individual pvalues of individual ADF
//   statitics
// - res('pi') = Individual lag order in individual ADF models
// - res('pmax') = Maximum Lag Order for individual ADF
//   regressions
// - res('Ti') = Adjusted Individual Size
// - res('ADF_tstats') = Individual ADF statistics
// - res('sample') =  Starting and Ending Dates of Adjusted
//   Sample
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
// uses the function Maddala_Wu1 translated and adapted from a
// Matlab program by: C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
// explode the arguments into the data, parameters and various
// objects
[Y,namey,prests,b,noprt,dropna,nonna,param]=explo_panelunitr(varargin(:))
 
// performs the estimation and stores the corresponding results
res = Maddala_Wu1(Y,param.t_order,param.lagorders,param.pmax,param.signif)
 
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
