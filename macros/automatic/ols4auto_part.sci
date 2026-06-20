function [results]=ols4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
// PURPOSE: the functions performing ordinary least squares in
// an automatic regression with partial results: x et y are
// supposed to be respectively a matrix, and a vector, a result
// structure already exists and can be filled
// ------------------------------------------------------------
// INPUT:
// * results: an existing tlist of regression results
// * y = dependent variable vector (nobs x 1)
// * x = original set of independent variables matrix
//       (nobs x nvar)
// * z = set of variables that are constrained to be in
// * varargin = an empty list of arguments (added to the input
//   of the function by confirmity with other functions that
//   can be called by the package automatic)
// ------------------------------------------------------------
// OUTPUT:
// a tlist with:
//        results('meth')  = 'ols'
//        results('y')     = y data vector
//        results('x')     = x data matrix
//        results('nobs')  = number of observations
//        results('nvar')  = number of exogenous variables
//        results('yhat')  = yhat
//        results('beta')  = bhat
//        results('tstat') = t-stats
//        results('pvalue') = corresponding pvalue
//        results('resid') = residuals
//        results('vcovar') = vcovar
//        results('sigu') = sigu
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013-2014
// http://grocer.toolbox.free.fr/grocer.html
 
 
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
