function [linv]=logn_inv(x,a,v)
 
// PURPOSE: computes inverse cdf (quantile) of the lognormal
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = variable vector (nx1)
// * a = mean vector (default=0)
// * v = variance vector (default=1)
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing pdf for each x
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by James P. Lesage,
// jpl@jpl.econ.utoledo.edu
// and adapted to scilab by Eric Dubois
 
[nargout,nargin] = argn(0)
if ~(nargin==1|nargin==3) then
  error('Wrong # of arguments to logn_inv');
end
 
if nargin==1 then
  a = 1;
  v = 1;
end
 
// The following """"straightforward"""" implementation unfortunately does
// not work (because exp (Inf) -> NaN):
// inv = exp (normal_inv (x, log (a), v));
// Hence ...
 
[retval,x,a,v] = com_size(x,a,v);
if retval>0 then
  error('logn_inv: x, m and v must be of common size or scalars');
end
 
[r,c] = size(x);
s = r*c;
x = matrix(x,1,s);
a = matrix(a,1,s);
v = matrix(v,1,s);
linv = zeros(1,s);
 
k = matrix(find(~(x>=0)|~(x<=1)|~(a>0)|~(a<%inf)|~(v>0)|~(v<%inf)),1,-1);
if or(k) then
  linv(k) = %nan*ones(1,max(size(k)))
end
 
k = matrix(find(((((x==1)&(a>0))&(a<%inf))&(v>0))&(v<%inf)),1,-1);
if or(k) then
  linv(k) = %inf*ones(1,max(size(k)))
end
 
k = matrix(find((((((x>0)&(x<1))&(a>0))&(a<%inf))&(v>0))&(v<%inf)),1,-1);
//sk=size(k,2)
if or(k) then
  linv(k) = a(k) .* exp(sqrt(v(k)) .* cdfnor("X",zeros(1,s),ones(1,s),x(k),1-x(k)))
end
 
linv = matrix(linv,r,c);
endfunction
