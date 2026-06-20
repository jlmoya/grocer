function [bhat,xpxi]=ols0(y,x)
 
// PURPOSE: the most basic least-squares regression: provides
// only bhat and the inverse of matrix x'*x
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// ------------------------------------------------------------
// OUTPUT:
// * bhat = estimated parameter
// * xpxi = inverse of matrix x'*x
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// ols1(), ols2()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
[xpxi,xpxixp]=invxpx(x)
bhat=xpxixp*y
 
endfunction
