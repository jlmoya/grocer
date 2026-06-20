function [dmat]=tdiff(x,k)
 
// PURPOSE: produce matrix differences
// ------------------------------------------------------------
// INPUT:
// * x = input matrix (or vector) of length nobs
// * k = lagged difference order
// ------------------------------------------------------------
// OUTPUT:
// * dmat = matrix or vector, differenciated by k-periods
// e.g. x(t) - x(t-k), of length nobs, (first k observations
// are zero)
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted (with correction) from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
// error checking on inputs
if nargin~=2 then
  error('Wrong # of arguments to tdiff');
end
 
[nobs,nvar] = size(x);
 
if k==0 then
  dmat = x;
else
  dmat = zeros(nobs,nvar);
  dmat(k+1:nobs,:) = x(k+1:nobs,:)-x(1:nobs-k,:);
end
 
endfunction
 
