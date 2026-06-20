function [pdf]=logn_pdf(x,a,v)
 
// PURPOSE: pdf of the lognormal distribution for each
// component of x with mean m, variance v
// ------------------------------------------------------------
// INPUT:
// * x = variable matrix (nxm)
// * a = mean matrix (nxm) or 1 (default=1)
// * v = variance matrix (nxm) (default=1)
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing pdf for each x
// ------------------------------------------------------------
// NOTES:
// * the logarithm of a lognormal random deviate is
//       normally distributed with mean = a and variance = v
// * could probably be improved and simplified in the line of
// what is made in gamma_pdf
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by JP LeSage, jpl@jpl.econ.utoledo.edu
// and translated to scilab by Eric Dubois
 
 
[nargout,nargin] = argn(0)
if ~(nargin==1|nargin==3) then
  error('Wrong # of arguments to logn_pdf');
end
 
if nargin==1 then
  a = 1;
  v = 1;
end
 
// The following """"straightforward"""" implementation
// unfortunately does not work for the special cases (Inf, ...)
// pdf = (x > 0) ./ x .* normal_pdf (log (x), log (a), v);
// Hence ...
 
[retval,x,a,v] = com_size(x,a,v);
if retval>0 then
  error('logn_pdf: x, m and v must be of common size or scalars');
end
 
[r,c] = size(x);
s = r*c;
x = matrix(x,1,s);
a = matrix(a,1,s);
v = matrix(v,1,s);
pdf = zeros(1,s);
 
k = matrix(find(isnan(x)|~(a>0)|~(a<%inf)|~(v>0)|~(v<%inf)),1,-1);
if or(k) then
  pdf(k) = %nan*ones(1,max(size(k)))
end
 
k = matrix(find((((((x>0)&(x<%inf))&(a>0))&(a<%inf))&(v>0))&(v<%inf)),1,-1);
if or(k) then
  %v1 = norm_pdf(log(x(k)),log(a(k)),v(k)) ./ x(k)
  pdf(1,k) = %v1(:).';
end
 
pdf = matrix(pdf,r,c);
 
endfunction
