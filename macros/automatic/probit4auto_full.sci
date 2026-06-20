function [results]=probit4auto_full(y,x,z,namey,namexos,namecomp,prests,boundsvar,dropna,ncomp,indx,list_vararg)
 
// PURPOSE: this is the full estimation of a probit model
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// * namexos = name of the exogenous variables
// * numx = index of the chosen exogenous variables
// (nobs x nvar')
// * prests = boolean equal to %T if there is a constant
// among the variables
// * results = a tlist already filled with
// ------------------------------------------------------------
// OUTPUT:
// results = a tlist with
//   . results('meth')  = 'ols'
//   . results('y')     = y data vector
//   . results('x')     = x data matrix
//   . results('nobs')  = nobs
//   . results('nvar')  = nvars
//   . results('beta')  = bhat
//   . results('tstat') = t-stats
//   . results('pvalue') = pvalue of the betas
//   . results('resid') = residuals
//   . results('vcovar') = estimated variance-covariance matrix
//     of beta
//   . results('sige')  = estimated variance of the residuals
//   . results('sigu')  = sum of squared residuals
//   . results('ser')  = standard error of the regression
//   . results('yhat')  = yhat
//   . results('dw')    = Durbin-Watson Statistic
//   . results('condindex') = multicolinearity cond index
//   . results('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . results('prests') = boolean indicating the presence or
//     absence of a ts in the regression
//   . results('namey') = name of the endogenous variable
//   . results('namex') = names of the exogenous variables
//   . results('ym') = mean of vector y
//   . results('spec_test') = vector of specification tests
//     p-values
//   . results('m_test') = vector of names of specification
//      tests
//   . results('ym') = mean of vector y
//   . results('rsqr')  = rsquared
//   . results('rbar')  = rbar-squared
//   . results('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . results('pvaluef') = its significance level
//   . results('namex') = name of the exogenous variable
// ------------------------------------------------------------
// NOTES:
// used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
results=probit2(y,x)
// saves the names, the bounds if the regression involves ts
results(1)($+1) = 'prests'
results(1)($+1) = 'namex'
results(1)($+1) = 'namey'
results(1)($+1) = 'dropna'
results('prests')=prests
results('namex')=[namecomp ; namexos]
results('namey')=namey
results('dropna')=dropna
 
if prests then
   results(1)($+1) = 'bounds'
   results('bounds')=boundsvar
end
 
if dropna then
   results(1)($+1)='nonna'
   results('nonna')=nonna
end
// duplicate beta in order to combine in with indx
// to give good starting
results(1)($+1)='beta0'
results('beta0')=results('beta')
 
endfunction
