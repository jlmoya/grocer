function [rn]=chis_rnd(n,v)
 
// PURPOSE: generates random chi-squared deviates
// ------------------------------------------------------------
// INPUT:
// *  n = a scalar for the size of the vector to be generated
// or n(1) = nrows, n(2) = ncols for a matrix to be generated
// *  v = the degrees of freedom
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing pdf for each x
// ------------------------------------------------------------
// NOTE:
// this a simple trasnpoition fo grand, but the function has
// been preserved for the sake of ascending compatibility
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to chis_rnd');
end
if ~(v>1) then
  error('chis_rnd: v must be > 1');
end
 
if size(n) == 1 then
   n=[n;1]
end
 
rn = grand(n(1),n(2),'chi',v)
 
endfunction
