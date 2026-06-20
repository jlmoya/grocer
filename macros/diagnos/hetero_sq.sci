function [resulh]=hetero_sq(r,np)
 
// PURPOSE: provides the value of the Xi² hetero test
// and its significance level
// ------------------------------------------------------------
// INPUT:
// * r = results tlist from a first stage estimation
// * np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUTPUT:
// resulh = a results tlist with:
// - resulth('meth')   = 'hagan'
// - resulth('resul1st') = results tlist of the first stage
//   regression
// - resulth('f') = Xi² Hetero statistics
// - resulth('p') = p-value of the test
// - resulth('dfnum') = degrees of freedom of the numerator
// - resulth('dfden') = degrees of freedom of the denominator
// - resulth('f_pvalue) = p-value of the test
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
[f,f_pvalue,nvar2]=hetero_sq0(r)
 
dfn=nvar2-1
dfd=r('nobs')-r('nvar')-nvar2
resulh=tlist(['resdiag';'meth';'resul1st';'f';...
'dfnum';'dfden';'f_pvalue'],...
'hetero_sq','resulols',f,dfn,dfd,f_pvalue)
 
if nargin == 1 then
   prtfish(resulh)
end
 
endfunction
