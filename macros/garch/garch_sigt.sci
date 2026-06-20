function [sigt]=garch_sigt(y,x,param,nar,nma)
 
// PURPOSE: generate garch model sigmas over time
//          given maximum likelihood estimates
// -------------------------------------------------------------
// INPUT:
// * y = data vector
// * x = data matrix
// * param = vector of parameters
// * nar = # of ar parameters
// * nma = # of ma parameters
// -------------------------------------------------------------
// OUTPUT:
// * (nx1) vector of sigma(t) estimates
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated to scilab from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[n,k] = size(x);
 
// transform parameters
[param] = garch_trans(param,k);
b=param(1:k)
a0=param(k+1)
ar=param(k+2:k+1+nar)
ma=param(k+2+nar:k+1+nar+nma)
 
nar=size(ar,1)
nma=size(ma,1)
nmax=max(nar,nma)
 
// compute residuals
e0 = y-x*b;
ssr0 = e0'*e0/n
e=[sqrt(ssr0)*ones(nmax,1) ; e0]
// generate sigt
sigt = [ssr0*ones(nmax,1) ; zeros(n,1)]
// initial variance
 
e = [sqrt(sigt(1))*ones(nmax,1) ; e]
 
for i = 1+nmax:n+nmax
    sigt(i) = param(k+1:k+1+nar+nma)'*[1 ; sigt(i-nar:i-1) ; e(i-nma:i-1).*e(i-nma:i-1)];
end
sigt=sigt(nmax+1:nmax+n)
endfunction
