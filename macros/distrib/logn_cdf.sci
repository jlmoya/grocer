function [cdf]=logn_cdf(x,a,v)
 
// PURPOSE: computes cdf of the lognormal distribution
// ------------------------------------------------------------
// INPUT:
// * x = variable vector (nx1)
// * a = mean vector (default=0)
// * v = variance vector (default=1)
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing cdf for each x
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by JP LeSage,
// jlesage@spatial-econometrics.com
// and adapted to scilab by Eric Dubois
 
 
[nargout,nargin] = argn(0)
if ~(nargin==1|nargin==3) then
  error('Wrong # of arguments to logn_cdf');
end
 
if nargin==1 then
  a = 1;
  v = 1;
end
 
// The following """"straightforward"""" implementation unfortunately does
// not work (because exp (Inf) -> NaN etc):
// cdf = normal_cdf (log (x), log (a), v);
// Hence ...
 
[retval,x,a,v] = com_size(x,a,v);
if retval>0 then
  error('logn_cdf: x, m and v must be of common size or scalars');
end
 
[r,c] = size(x);
s = r*c;
x = matrix(x,1,s);
a = matrix(a,1,s);
v = matrix(v,1,s);
cdf = zeros(1,s);
 
k = matrix(find(isnan(x)|~(a>0)|~(a<%inf)|~(v>0)|~(v<%inf)),1,-1);
if or(k) then
  cdf(k) = %nan*ones(1,max(size(k)))
end
 
k = matrix(find(((((x==%inf)&(a>0))&(a<%inf))&(v>0))&(v<%inf)),1,-1);
if or(k) then
  cdf(k) = ones(1,max(size(k)))
end
 
k = matrix(find((((((x>0)&(x<%inf))&(a>0))&(a<%inf))&(v>0))&(v<%inf)),1,-1);
if or(k) then
  %v1 = cdfnor("PQ",(log(x(k))-log(a(k))) ./ sqrt(v(k)),zeros(1,s),ones(1,s))
  cdf(1,k) = %v1(:).';
end
 
cdf = matrix(cdf,r,c);
 
endfunction
