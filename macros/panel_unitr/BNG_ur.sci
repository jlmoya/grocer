function res = BNG_ur(varargin)
 
// PURPOSE: Bai and Ng (2004) test of unit root "A PANIC
// attack on unit root and cointegration", Econometrica,
// vol; 72, n°4, p.1127-1177.
// ------------------------------------------------------------
// INPUT:
// varargin = arguments that can be:
// * a panel data tlist (in that case there must be an argument
//   'namevar=xxx' to indicate the name of the variable in the
//    panel, see below)
// * the strings:
//   - 't_order=x' for the trend order:
//      -1: no constant, no trend
//       0: a constant, no trend (default)
//       1: a constant and a trend
//   - 'typeoflag = x' where x is the string:
//     . 'common' if the lag order is common to all variables
//    (in that case, the lag order is determined as in Bai and
//    Ng ,2004)
//     . 'individual' if the lag order is optimally chosen for
//   each variable
//   - 'pmax=x' with x=%nan or a number if for the maximal # of
//   lags for the ADF test
//  - 'kmax=x' where x is the maximum number of common factors
//   used to compute the criterion functions for the estimation
//   of r, the numberof common factors. It is not specified
//   kmax=min(N,T)
//   - 'criteria=x' with x = Criterion used to estimate the
//      number of common factors
//            = 'IC1', 'IC2', 'IC3', 'PC1', 'PC2', 'PC3',
//              'AIC3', 'BIC3'
//            (see Bai and Ng (2002))
//   - 'signif=x' with x the significance level
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
// - res('meth') = 'BNG panel ur test'
// - res('y') = (T x k) matrix of data
// - res('t_order') = the trend order (-1, 0 or 1)
// - res('t_orderlit') = the trend order in plain english
// - res('ratio1') = Variance of idyosyncratic component divised
//   by the variance observed data (both in first differences)
// - res('ratio2') = Variance of residuals of common components
//   divised by variance on idyosyncratic component
// - res('ADFe') = Individual ADF statistics on idyosincratic
//   component : ADFe(i)
// - res('ADFe_pvalue') = Individual ADF statistics on
//   idyosincratic component : ADFe(i)
// - res('ADFe_pi') = Number of ADF terms in ADF tests on e(i,t)
// - res('pmax') = Maximum Lag Order for individual ADF
//   regressions on e(i,t)
// - res('ADFe_Ti') = Adjusted time dimension for ADF tests on
//   e(i,t)
// - res('nbfactors') = Estimated number of common factors
// - res('khat') = Estimated Numbers of Factor with IC1, IC2,
//   IC3, PC1, PC2, PC3, AIC3 and BIC3
// - res('criteria') = Criteria used to estimate the number of
//   common factors. Default value = 1 (IC1)
// - res('IC') = IC1, IC2 and IC3 Information criteriums
//   for r=1,..,kmax
// - res('PC') = PC1, PC2 and PC3 Information criteriums
//   for r=1,..,kmax
// - res('BIC3') = BIC3 Information criterium for k=1,..,kmax
//   (only BIC criteria function of N and T)
// - res('AIC3') = AIC3 Information criterium (only AIC criteria
//   function of N and T) : it tends to overestimate r
// - res('kmax') = Maximum number of common factors authorized
//       When there is one common factor (r=1):
//       **************************************
// - res('BNG.ADF_F') = ADF statistic on common factor: ADFf
// - res('BNG.ADF_F_pvalue') = Pvalue associated to ADFf
// - res('ADF_F_pi') = Number of ADF terms in ADF tests on
//   e(i,t)
// - res('ADF_F_Ti') = Adjusted time dimension for ADF tests
//   on e(i,t)
//       When there is more than one common factor (r>1):
//       ************************************************
// - res('MQc') = MQc(m) Statistics with critical values at 1%,
//   5% and 10% for m=r,..,1
// - res('MQf') = MQf(m) Statistics with critical values at 1%,
//   5% and 10% for m=r,..,1
// - res('MQc_r1') = Number of Common Stochastic Trends at 1%,
//   5% and 10% (MQc Test)
// - res('MQf_r1') = Number of Common Stochastic Trends at 1%,
//   5% and 10% (MQf Test)
// - res('MQf_p') = Optimal lag order for the VAR(p) on dYc
//   (MQf test)
//       If t_order == 1:
//       ****************
// - res('PCe_Choi') = Pooled test standardized statistic
//  (Choi 2001) on idiosyncratic components e: N(0,1) under H0
// - res('PCe_Choi_critical') = Critical Values of the pooled
//   test statistic (Choi, 2001) at 1%, 5% and 10%
// - res('PCe_Choi_pvalue') = Pvalue Pooled test statistic
//  (Choi 2001)
// - res('PCe_MW') = Pooled test statistic (Maddala Wu 1999)
//  on idiosyncratic components e : X(2N) under H0
// - res('PCe_MW_critical') = Critical Values of the pooled
//   test statistic (Maddala Wu 1999) at 1%, 5% and 10%
// - res('PCe_MW_pvalue') = Pvalue Pooled test statistic
//   (Maddala Wu 1999)
// - res('prests') = boolean indicating the presence or
//   absence of a time series in the regression
// - res('namey') = name of the y variable
// - res('dropna') = boolean indicating if NAs have
//	 been dropped
// - res('bounds') = if there is a time series in the
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
res = BNG_ur1(Y,param.t_order,param.typeoflag,param.pmax,param.kmax,param.criteria,param.signif)
 
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
