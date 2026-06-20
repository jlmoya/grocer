function [xpxi,xpxixp]=invxpx(x)
 
// PURPOSE: provide inversion of the matrix (x'x) using the
// QR decomposition
// ------------------------------------------------------------
// INPUT:
// x = a (n x k) real matrix
// ------------------------------------------------------------
// OUTPUT:
// * xpxi = the (k x k) matrix equal to inv(x'x)
// * xpxixp = the (k x T) matrix equal to inv(x'x)*x'
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// ols0(), ols1(), ols2()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2020
// http://grocer.toolbox.free.fr/grocer.html
 
[q,r]= qr(x,'e')
xpxixp=r\q'
xpxi=xpxixp*xpxixp'
 
endfunction
