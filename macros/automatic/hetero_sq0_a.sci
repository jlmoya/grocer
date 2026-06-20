function [f,f_pvalue,nvar2,r2]=hetero_sq0_a(r,np)
 
// PURPOSE: provides the value of the Xi² hetero test
// and its significance level; special version for automatic
// that takes into account the possibility that there are more
// regressors than observations; in that case the test is not
// performed but is supposed to pass
// ------------------------------------------------------------
// INPUT:
// * r = results tlist from a first stage estimation
// * np = unused argument put for compatibility with other
// testing functions
// ------------------------------------------------------------
// OUPTUT:
// * f = value of the Xi² hetero F test
// * f_pvalue = its p-value
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
nvar=r('nvar')
nobs=r('nobs')
u2=r('resid').^2
x=r('x')
ind_cte=search_cte(x)
if ~isempty(ind_cte) then
   x(:,ind_cte)=[]
end
xd=[x x .^2]
[u,d,v] = svd(xd,'e');
lamda = diag(d);
ratio_lamda=(lamda/lamda(1)).^2
if ratio_lamda($) < 1E10 then
   ind_kept=find(ratio_lamda>=sqrt(%eps))
   xd=u(:,ind_kept)*d(ind_kept,ind_kept)*v(ind_kept,ind_kept)'
end
 
if nobs-nvar-size(xd,2) > 0 & size(xd,2) > 0 then
   [f,f_pvalue,nvar2,r2]=bpagan0(u2,[ones(nobs,1) xd],nvar)
else
// either there are too many regressors in the auxiliary regression
// or there is only the constant term
   f=0
   f_pvalue=1
end
 
endfunction
