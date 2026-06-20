function [scale]=scstd(y,nobs,nlag)
 
// PURPOSE: determines bvar() function scaling factor using a
//          univariate AR model (called by bvar1() only)
// ------------------------------------------------------------
// INPUT:
// * y    = an (nobs x neqs) matrix of y-vectors in levels
// * nobs = # of observations in y
// * nlag = the lag length
// ------------------------------------------------------------
// OUTPUT:
// * scale = std deviation of the residuals
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// tanslated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
 
ylag = mlagb(y,nlag);
ylag = [ylag,ones(nobs,1)];
 
// truncate to feed the lag
xmat = ylag(nlag+1:nobs,:);
yvec = y(nlag+1:nobs,1);
 
n = size(yvec,1);
 
b = ols0(yvec,xmat);
e = yvec-xmat*b;
sige = e'*e/(n-2);
sige = sige/(nobs-nlag);
 
scale = sqrt(sige);
endfunction
