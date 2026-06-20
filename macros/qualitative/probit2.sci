function res=probit2(y,x,b0)
 
// PURPOSE: computes Probit Regression
// ------------------------------------------------------------
// References: Arturo Estrella (1998) 'A new measure of fit
// for equations with dichotmous dependent variable', JBES,
// Vol. 16, #2, April, 1998.
// ------------------------------------------------------------
// INPUT:
// * namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
//  vector between quotes; all values should be 0 or 1
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'maxit=xx' if the user wants to set the
//     maximum # of iterations to xx (default=100)
//   . the string 'grocer_tol=xx' if the user wants to set the
//     convergence criterion to xx (default=1e-6)
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with
//   . res('meth')  = 'probit'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = # observations
//   . res('nvar')  = # variables
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('r2mf')  =  = McFadden pseudo-R²
//   . res('rsqr')  =  = Estrella R²
//   . res('lratio') = LR-ratio test against intercept model
//   . res('lik')    = unrestricted Likelihood
//   . res('zip')    = # of 0's
//   . res('one)    = # of 1's
//   . res('iter')   = # of iterations
//   . res('crit')   = convergence criterion
//   . res('namey') = name of the y variable
//   . res('namex') = name of the x variables
//   . res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . res('prescte') = %f (for printings)
//   . res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . res('dropna') = boolean indicating if NAs have
//		   been dropped
//   . res('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of grocer_toledo
// 2801 W. Bancroft St,
// grocer_toledo, OH 43606
// jpl@jpl.econ.ugrocer_toledo.edu
 
[nargout,nargin]=argn(0)
if nargin < 3 then
   b0 = ols0(y,x)
   b0=b0/max(abs(x*b0));
end
 
[b,yhat,tstat,pvalue,resid,covb,like1,nobs,nvar]=probit1(y,x,b0)
tmp = matrix(find(y==1),1,-1);
P = max(size(tmp));
cnt0 = nobs-P;
cnt1 = P;
// proportion of 1's
P = P/nobs
// restricted likelihood
like0 = nobs*(P*log(P)+(1-P)*log(1-P));
 
res = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'yhat';'resid';'vcovar';'tstat';'pvalue';...
'llike';'llike0';'lratio';'rsqr';'r2mf';'condindex';...
'aic';'bic';'hq'],...
'probit',y,x,nobs,nvar,...
b,yhat,resid,covb,tstat,pvalue,...
like1,like0)
 
res=probit_update(res,x)
 
endfunction
