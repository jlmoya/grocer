function results=ppooled4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
// PURPOSE: performs Fixed Effects Estimation for Panel Data
// (for balanced or unbalanced data) using the within-groups
//     estimation procedure.
// ------------------------------------------------------------
// INPUT:
// * y = a (nobs x neqs) matrix of all of the individual's
//   observations vertically concatenated. This matrix must
//   include in the first column the dependent variable, the
//   independent variables must follow accordingly.
// * index = index vector that identifies each observation with
//   an individual
//   e.g. 1  (first 2 observations  for individual # 1)
//        1
//        2  (next  1 observation   for individual # 2)
//        3  (next  3 observations  for individual # 3)
//        3
//        3
// * z = optional matrix of exogenous variables, dummy
//   variables.
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . rpanel('meth')='panel with fixed effects'
//   . rpanel('y')     = y data vector
//   . rpanel('x')     = x data matrix
//   . rpanel('nobs')  = nobs
//   . rpanel('nvar')  = nvars
//   . rpanel('beta')  = bhat
//   . rpanel('yhat')  = yhat
//   . rpanel('resid') = residuals
//   . rpanel('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rpanel('sige')  = estimated variance of the residuals
//   . rpanel('sigu')  = sum of squared residuals
//   . rpanel('ser')  = standard error of the regression
//   . rpanel('tstat') = t-stats
//   . rpanel('pvalue') = pvalue of the betas
//   . rpanel('condindex') = multicolinearity cond index
//   . rpanel('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rpanel('lliked') = log-likelihood
//   . rpanel('rsqr')  = rsquared
//   . rpanel('rbar')  = rbar-squared
//   . rpanel('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rpanel('pvaluef') = its significance level
// ------------------------------------------------------------
// Copyright: Eric Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adpated from Matlab programs
// Written by:
// Carlos Alberto Castro
// National Planning Department
// Bogota, Colombia
// Email: ccastro@dnp.gov.co
 
xpath=[z x]
[nobs,nvar]=size(xpath)
 
[q,r]= qr(xpath,'e')
ir=inv(r)
bet=ir*q'*y
 
yhat = xpath*bet
resid = y-yhat
sigu =resid'*resid
vcovar=sigu/(nobs-nvar)*ir*ir'
tstat = bet ./ sqrt(diag(vcovar))
 
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),nobs-nvar))*2
end
 
results('x') = xpath
results('nvar')  = nvar
results('yhat')  = yhat
results('beta')  = bet
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resid
results('vcovar') = vcovar
results('sigu') = sigu
 
endfunction
