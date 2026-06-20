function [f,f_pvalue]=reset0(r,npow,np)
 
// PURPOSE: Ramsey (1969) linearity test
// ------------------------------------------------------------
// INPUT:
// * r = the first stage regression tlist result
// * npow = degree of non linearity
// ------------------------------------------------------------
// OUPTUT:
// * f = value of the Goldfeld-Quandt F test
// * f_pvalue = its p-value
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
y=r('y')
x2=r('x')
for i=2:npow
   x2=[x2 r('yhat').^i]
end
u=y-x2*ols0(r('y'),x2)
[nobs,nvar2]=size(x2)
f=(r('sigu')/(u'*u)-1)*(nobs-nvar2)/(npow-1)
f_pvalue=1-cdff("PQ",f,npow-1,nobs-nvar2)
endfunction
