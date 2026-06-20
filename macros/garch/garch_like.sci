function [llik]=garch_like(parm,nar,nma,y,x)
 
// PURPOSE: log likelihood for garch model
// ------------------------------------------------------------
// INPUT:
// * parm = a vector of parmeters
//        parm(1) = beta 1
//        parm(2) = beta 2
//        .
//        .
//        .
//        parm(k) = beta k
//        parm(k+1) = a0
//        parm(k+2) = ar(1)
//        .
//        .
//        .
//        parm(k+nar+1) = ar(nar)
//        parm(k+nar+1) = ma(1)
//        .
//        .
//        .
//        parm(k+nar+nma+1) = ar(nma)
// * y = (n x 1) vector of the endogenous variable
// * x = (n x k) vector of the exogenous variables
// * nar = # of ar coefficient in the garch model
// * nma = # of ma coefficient in the garch model
// ------------------------------------------------------------
// OUTPUT:
// -log likelihood function value (a scalar)
// ----------------------------------------------------
// REFERENCES: Green (2000) Econometric Analysis
// ----------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometics.com
 // compute residuals
 
n = size(y,1); // in case of x is empty
k = size(x,2);
 
b=parm(1:k)
 
// transform parameters
[parm] = garch_trans(parm,k);
 
// compute residuals
if k == 0 then
   e0=y
else
   e0 = y-x*b;
end
ssr0 = e0'*e0/n
e=[sqrt(ssr0)*ones(nma,1) ; e0]
// generate sigt and log likelihood
sigt = [ssr0*ones(nar,1) ; zeros(n,1)]
for i = 1:n
   sigt(i+nar) = parm(k+1:k+1+nar+nma)'*[1 ; sigt(i+nar-1:-1:i) ; e(i+nma-1:-1:i).*e(i+nma-1:-1:i)];
//   sigt(i+nar) = parmt(k+1:k+1+nar+nma)'*[1 ; sigt(i+nar-1:-1:i) ;...
//             res(i+nma-1:-1:i).*res(i+nma-1:-1:i)];
end
sigt=sigt(1+nar:n+nar)
loglik = 0.5*(log(2*%pi)+log(sigt)+(e0 .* e0)./sigt);
llik = sum(loglik);
 
endfunction
