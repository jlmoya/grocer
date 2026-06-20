function [dh,pn]=doornhans0(resid,np)
 
// PURPOSE : "omnibus" normality test
// ------------------------------------------------------------
// references : J. Doornik and H. Hansen (1994) : "A practical
// test for univariate and multivariate normality", Discussion
// Paper, Nuffield College
// ------------------------------------------------------------
// INPUT:
// * res = a result tlist or a T x p) matrix of residuals
// * np= unused argument put for compatibility with other
//   testing functions
// ------------------------------------------------------------
// OUTPUT:
// * dh = the value of the test
// * pn = its p-value
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(resid) == 'results' then
   resid=resid('resid')
end
[nobs,nresid]=size(resid)
mresid=sum(resid,'r')/nobs
residc=resid-(mresid .*. ones(nobs,1))
sigma=residc'*residc/nobs
 
if nresid > 1 then
   V=diag(1 ./ sqrt(diag(sigma)))
   C=V*sigma*V
   invsqrtC=real(C)^(-0.5)
   resid_std=resid*V*invsqrtC
//   [H,gam]=spec(C)
//   resid_std=resid*V*H'*sqrt(gam)*H
else
   resid_std=resid/sqrt(sigma)
end
 
m3 = sum(resid_std .^3,'r')/nobs
m4 = sum(resid_std .^4,'r')/nobs
 
bet=3*(nobs^2+27*nobs-70)*(nobs+1)*(nobs+3)/(nobs-2)/(nobs+5)/(nobs+7)/(nobs+9)
om2=-1+sqrt(2*(bet-1))
delta=log(sqrt(om2))^(-0.5)
y=m3*sqrt((om2-1)*(nobs+1)*(nobs+3)/12/(nobs-2))
s=delta*log(y+sqrt(y .^2+1))
 
delta=(nobs-3)*(nobs+1)*(nobs^2+15*nobs-4)
a=(nobs-2)*(nobs+5)*(nobs+7)*(nobs^2+27*nobs-70)/6/delta
c=(nobs-7)*(nobs+5)*(nobs+7)*(nobs^2+2*nobs-5)/6/delta
k= (nobs+5)*(nobs+7)*(nobs^3+37*nobs^2+11*nobs-313)/12/delta
alpha=a+m3 .^ 2*c
khi=(m4-1-m3 .^2)*2*k
k=((khi/2 ./alpha).^(1/3)-1+1/9 ./alpha).*sqrt(9*alpha)
 
dh = sum(s .^2)	 + sum(k .^2) ;
pn = 1 - cdfchi("PQ",dh,2*nresid)
 
endfunction
