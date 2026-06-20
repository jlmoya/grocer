function [results]=nwest4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
// PURPOSE: the functions performing ordinary least squares in
// an automatic regression with partial results: x et y are
// supposed to be respectively a matrix, and a vector, a result
// structure already exists and can be filled
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = original set of independent variables matrix
//       (nobs x nvar)
// * z = set of variables that are constrained to be in
// * results: an existing tlist of regression results
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
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
win=list_vararg(1)
 
[nobs,nvar]=size(x)
 
[bet,xpxi]=ols0(y,x)
yhat = x*bet
resid = y-yhat
sigu =resid'*resid
emat=ones(nvar,1) .*. resid'
 
hhat=emat .* x'
xuux=hhat(:,1:nobs)*hhat(:,1:nobs)'
 
for i=1:win
   zi=hhat(:,(i+1):nobs)*hhat(:,1:nobs-i)'
   gi=zi+zi'
   xuux=xuux+(1-i/(win+1))*gi
end
 
xpxia = xpxi*xuux*xpxi;
tmp = sqrt(diag(xpxia));
tstat=bet ./ tmp
 
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),nobs-nvar))*2
end
 
results('x') = x
results('nvar')  = nvar
results('yhat')  = yhat
results('beta')  = bet
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resid
results('vcovar') = xpxia
results('sigu') = sigu
 
endfunction
