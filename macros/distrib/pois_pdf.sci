function [pdf]=pois_pdf(x,l)
 
// PURPOSE: computes the normal probability density function
// at x of the Poisson distribution with parameter lambda
// ------------------------------------------------------------
// INPUT:
// * x = variable vector (nxm)
// * l = value at which to evaluate pdf
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing pdf for each x
// ------------------------------------------------------------
// Author: Kurt Hornik
// <Kurt.Hornik@ci.tuwien.ac.at>
// Copyright Dept of Probability Theory and Statistics TU Wien
// Converted to MATLAB by JP LeSage, jpl@jpl.econ.utoledo.edu,
// and to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('poisson_pdf: Wrong # of inputs');
end
 
[retval,x,l,junk] = com_size(x,l,l);
if retval>0 then
  error('pois_pdf: x and lambda must be of common size or scalar');
end
 
[r,c] = size(x);
s = r*c;
x = matrix(x,1,s);
l = matrix(l,1,s);
pdf = zeros(1,s);
 
k = matrix(find(~(l>0)|isnan(x)),1,-1);
if or(k) then
  pdf(k) = %nan*ones(1,max(size(k)))
end
 
k = matrix(find((((x>=0)&(x<%inf))&(x==round(x)))&(l>0)),1,-1);
if or(k) then
  pdf(k) = exp(x(k) .* log(l(k))-l(k)-gammaln(x(k)+1))
end
 
pdf = matrix(pdf,r,c);
 
 
endfunction
