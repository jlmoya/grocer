function [jb,pn,s,k]=jbnorm_var1(y)
 
// PURPOSE : Jarque and Bera normality test for a vector
// ------------------------------------------------------------
// references : Jarque, C. M., and Bera, A. K. (1980). '
// Efficient tests for normality, homoscedasticity and serial
// independence of regression residuals', Economics Letters, 6,
// 255�259.
// ------------------------------------------------------------
// INPUT:
// * y = a (n x 1) vector
// ------------------------------------------------------------
// OUTPUT:
// * jb = the value of the test
// * jn = its p-value
// * s = the skewness of the residuals
// * k = the kurtosis of the residuals
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
 
my=mean0(y)
n = size(y,1)
m2 = sum( (y-my).^2 )/n
m3 = sum( (y-my).^3 )/n
m4 = sum( (y-my).^4 )/n
 
s = n^2/(n-1)/(n-2)/sqrt(6*n*(n-1)/(n-2)/(n+1)/(n+3))*m3/(m2^1.5)
k = n^2*(n+1)/(n-1)/(n-2)/(n-3)/sqrt(24*n*(n-1)^2/(n-3)/(n-2)/(n+3)/(n+5))...
      *(m4/(m2^2)-3*(n-1)^2/(n-2)/(n-3) );
 
jb = s^2 + k^2 ;
pn = 1 - cdfchi("PQ",jb,2)
 
endfunction
