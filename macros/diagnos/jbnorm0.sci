function [jb,pn,s,k]=jbnorm0(res,np)
 
// PURPOSE : Jarque and Bera normality test
// ------------------------------------------------------------
// references : Jarque, C. M., and Bera, A. K. (1980). '
// Efficient tests for normality, homoscedasticity and serial
// independence of regression residuals', Economics Letters, 6,
// 255–259.
// ------------------------------------------------------------
// INPUT:
// * res = a result tlist
// * np= unused argument put for compatibility with other
//   testing functions
// * s = the skewness of the residuals
// * k = the kurtosis of the residuals
// ------------------------------------------------------------
// OUTPUT:
// * jb = the value of the test
// * jn = its p-value
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
 
resid=res('resid')
mresid=mean0(resid)
k = res('nvar')
n = res('nobs')
m2 = sum( (resid-mresid).^2 )/n
m3 = sum( (resid-mresid).^3 )/n
m4 = sum( (resid-mresid).^4 )/n
s = n^2/(n-1)/(n-2)/sqrt(6*n*(n-1)/(n-2)/(n+1)/(n+3))*m3/(m2^1.5)
k = n^2*(n+1)/(n-1)/(n-2)/(n-3)/sqrt(24*n*(n-1)^2/(n-3)/(n-2)/(n+3)/(n+5))...
    *(m4/(m2^2)-3*(n-1)^2/(n-2)/(n-3) );
 
jb = s^2 + k^2 ;
pn = 1 - cdfchi("PQ",jb,2)
 
endfunction
