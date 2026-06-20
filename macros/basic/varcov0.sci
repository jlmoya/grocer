function m=varcov0(z)
 
// PURPOSE: calculate the variance-covariance matrix of z
// columns
// ------------------------------------------------------------
// INPUT:
// z = a (nxk) matrix
// ------------------------------------------------------------
// OUTPUT:
// m = the (kxk) variance-covariance
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nobs=size(z,1)
zm=z- (mean0(z,'r').*.ones(nobs,1))
m=zm'*zm/(size(z,1)-1)
 
endfunction
 
