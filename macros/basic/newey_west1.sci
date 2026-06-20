function nw=newey_west1(resid,l)
 
// PURPOSE: perform the Newey_West variance estimator
// if no truncation lag (l) is provided by the user,
// then it is fixed at floor(5*nobs^0.25)
// ------------------------------------------------------------
// INPUT:
// * x = input matrix or vector, (nobs x k)
// * l = order of lag (optional)
// ------------------------------------------------------------
// OUTPUT:
// nw = matrix (or vector) of lags (nobs x k)
// ------------------------------------------------------------
// NOTES:
// * if l <= 0, nw = [] is returned. While you may find this
// perverse, it is sometimes useful.
// * should presumably be made more efficient
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nobs=size(resid,1)
nw=resid'*resid
for j=1:l
   nw=nw+2*(1-j/(l+1))*(resid(1:nobs-j)'*resid(j+1:nobs))
end
nw=nw/nobs
 
endfunction
 
