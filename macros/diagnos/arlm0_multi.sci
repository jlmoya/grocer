function [lmf,pvalue]=arlm0_multi(res,lags,np)
 
// PURPOSE: LM multivariate test of autocorrelation
// ------------------------------------------------------------
// INPUT:
// * res = results tlist from a first stage estimation
// * lags = vector of lags of residuals in the second stage
//   estimation
// * np = unused argument (but put here for compatibility with
//   other testing functions)
// ------------------------------------------------------------
// OUTPUT:
//  * lmf = value of the statistic
//  * pvalue = its p-value
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
if or(res('meth') == ['ms var' ; 'ms regression' ; 'ms mean'])
   u=res('smoothed resid')
   T=res('nobs')
   n=res('nendo')
   s=size(lags,'*')
   x=[res('xmat') , res('zmat')]
   nvar=res('n_x')+res('n_z')
 
else
   u=res('resid')
   T=res('nobs')
   n=res('neqs')
   s=size(lags,'*')
   x=res('x')
   nvar=res('nvar')
end
 
p=s*n
r=sqrt(((n*p)^2-4)/(n^2+p^2-5))
q=0.5*n*p-1
if size(nvar,'*') == n then
   N=T-sum(nvar)/n-p-0.5*(n-p+1)
else
   N=T-res(nvar)-p-0.5*(n-p+1)
end
 
tsig0=u'*u
if size(x,1) == T then
   // rescale the residuals to obtain better estimates
   for i=1:s
      x=[x (lag(u,lags(i),0)*mean0(abs(x))./(mean0(abs(u),'r').*.ones(T,1)))]
   end
   resid=u-x*ols0(u,x)
else
   for i=1:s
      x=[x eye(n,n) .*. (lag(u,lags(i),0)*mean0(abs(x))./(mean0(abs(u),'r').*.ones(T,1)))]
   end
   u=u(:)
   resid=matrix(u-x*ols0(u,x),T,n)
 
end
 
tsiga=resid'*resid
lmf=(real(det(tsig0)/det(tsiga))^(1/r)-1)*(N*r-q)/n/p
pvalue=1-cdff("PQ",lmf,n*p,round(N*r-q))
 
endfunction
