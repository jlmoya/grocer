function res = Pesaran(varargin)
 
// PURPOSE: Pesaran (2007) unit root test "A simple panel
// unit root test in the presence of cross-section dependence",
// Journal of Applied Econometrics, John Wiley & Sons, Ltd.,
// vol. 22(2), pages 265-312.
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
//    - 'signif=x' with x the signifance level
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
// -  res('meth') = 'Pesaran'
// -  res('y') = (T x k) matrix of data
// -  res('t_order') = the trend order (-1, 0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('CIPS') = CIPS statistic
// -  res('CIPS_star') = Truncated CIPS : CIPS* statistic
// -  res('CIPS_pvalue') = Pvalue of the CIPS statistic
// -  res('CIPS_star_pvalue') = Pvalue of the truncated CIPS* statistic
// -  res('CIPS_critical') = Critical Values of the CIPS distribution at 1%, 5% and 10% for T and N sample
// -  res('CADF') = Individual CADF statistics
// -  res('CADF_pvalue') = Pvalues of the individual CADF statistics (based on the CADF distribution)
// -  res('CADF_critical') = Critical Values of the CADF distribution at 1%, 5% and 10% for T and N sample
// -  res('CADF_star') = Truncated individual CADF statistics
// -  res('CADF_star_critical') = Critical Values of the CADF distribution at 1%, 5% and 10% for T and N sample
// -  res('CADF_star_pvalue') = Pvalues of the individual truncated CADF_star statistics (based on the CADF distribution)
// -  res('p') = Lag order in the CADF regressions (common for all individuals)
// -  res('CP') = Chi-Squared test statistic CP
// -  res('CZ') = Inverse normal test statistic CZ
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
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
// explode the arguments into the data, parameters and various
// objects
[Y,namey,prests,b,noprt,dropna,nonna,param]=explo_panelunitr(varargin(:))
 
// performs the estimation and stores the corresponding results
res = Pesaran1(Y,param.t_order,param.lagorders,param.pmax,param.signif)
 
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
