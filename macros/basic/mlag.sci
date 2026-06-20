function [xlag]=mlag(x,n,init)
 
// PURPOSE: generate a matrix of n lags from a matrix (or
// vector) containing a set of vectors (For use in var
// routines)
// ------------------------------------------------------------
// INPUT:
// * x = a matrix (or vector), nobs x nvar
// * n = # of contiguous lags for each vector in x
// * init = (optional) scalar value to feed initial missing
// values (default = 0)
// ------------------------------------------------------------
// OUTPUT:
// * xlag = a matrix of lags (nobs x nvar*nlag)
// * x1(t-1), x1(t-2), ... x1(t-nlag), x2(t-1), ... x2(t-nlag)
// ...
// ------------------------------------------------------------
// NOTES:
// see also lag() which works more conventionally
// ------------------------------------------------------------
// translated by Eric Dubois from:
// http://grocer.toolbox.free.fr/grocer.html
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
 
if nargin==1 then
  n = 1;
  // default value
  init = 0;
elseif nargin==2 then
  init = 0;
end
 
if nargin>3 then
  error('mlag: Wrong # of input arguments');
end
 
[nobs,nvar] = size(x);
 
xlag = ones(nobs,nvar*n)*init;
icnt = 0;
for i = 1:nvar
  for j = 1:n
    xlag(j+1:nobs,icnt+j) = x(1:nobs-j,i);
  end
  icnt = icnt+n;
end
 
endfunction
 
