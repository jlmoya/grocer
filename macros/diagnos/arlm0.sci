function [fstat,f_pvalue,r2]=arlm0(resulols,p,np)
 
// PURPOSE: LM test of autocorrelation
// ------------------------------------------------------------
// INPUT:
// * resul1 = results tlist from a first stage estimation
// * p = # of lag of residuals in the second stage estimation
// * np = unused argument (but put here for compatibility with
//   other testing functions)
// ------------------------------------------------------------
// OUPTUT:
//  * fstat = value of the statistic
//  * f_pvalue = its p-value
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2010
// http://grocer.toolbox.free.fr/grocer.html
 
u=resulols('resid')
x0=resulols('x')
// rescale the residuals to obtain better estimates
x=[x0 mlag0(u,p,0)*mean0(abs(x0))/mean(abs(u))]
resid=u-x*ols0(u,x)
sigu=resid'*resid
 
r2=1-sigu/resulols('sigu')
df=resulols('nobs')-resulols('nvar')-p
fstat=(resulols('sigu')/sigu-1)*df/p
f_pvalue=1-cdff("PQ",fstat,p,df)
 
endfunction
