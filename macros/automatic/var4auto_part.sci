    function [results]=var4auto_part(results,y,x,z,ncomp,indx,crit,itmax,nlags,yall,ncomp,list_vararg)
 
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
//        results('meth')  = 'restricted var'
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
crit=list_vararg(1)
itmax=list_vararg(2)
nlags=list_vararg(3)
yall=list_vararg(4)
 
xpath=[z x]
[bet,resid,yhat,sigma,ixpomegam1x,ncoeffeqs]=sur0(y,xpath,crit,itmax)
 
tstat=bet ./sqrt(diag(ixpomegam1x))
pvalue=0*bet
 
for i=1:size(bet,1)
   pvalue(i)=(1-cdfnor("PQ",abs(tstat(i)),0,1))*2
end
 
nobs=results('nobs')
neqs=results('neqs')
resn=matrix(resid,nobs,neqs)
llike=-0.5*nobs*neqs*log(2*%pi)-0.5*nobs*log(det(resn'*resn/nobs))-0.5*nobs*neqs
 
results('x') = xpath
results('nvar')  = ncoeffeqs
results('yhat')  = yhat
results('beta')  = bet
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resn
results('vcovar') = ixpomegam1x
results('sigma') = sigma
results('llike') = llike
 
endfunction
