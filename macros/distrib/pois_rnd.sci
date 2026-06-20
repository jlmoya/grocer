function [y]=pois_rnd(n,lambda)
 
// PURPOSE: generate random draws from the possion distribution
// ------------------------------------------------------------
// INPUT:
// *  n = a scalar for the size of the vector to be generated
// or n(1) = nrows, n(2) = ncols for a matrix to be generated
// * lambda = mean used for the draws
// ------------------------------------------------------------
// OUTPUT:
// y = a vector of draws
// ------------------------------------------------------------
// NOTES:  maintained for the sake of asending compatibilty...
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to pois_rnd');
end
 
if size(n) == 1 then
   n=[n;1]
end
y=grand(n(1),n(2),'poi',lambda)
 
endfunction
