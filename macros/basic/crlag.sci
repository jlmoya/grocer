function [y]=crlag(x,n)
 
// PURPOSE: circular lag function
// -----------------------------------------------------
// INPUT:
// * x = input vector (tx1) or (1xt)
// * n = # of values to return (optional; default=t)
// -----------------------------------------------------
// OUTPUT:
// y = a (nx1) (if x is (1xt)) or a (1xn) (if x is (1xt))
// vector with:
// * y(1) = x(n)
// * y(2) = x(1)
//    .
// * y(n) = x(n-1)
// -----------------------------------------------------
// Copyright Eric Dubois 20002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargin,nargout]=argn(0)
[n,m]=size(x)
if min(n,m) ~= 1 then
   error('input # 1 in crlag should be a vector')
end
if nargin == 1 then
   n=max(n,m)
end
 
y=x([1:n])
y([2:n]) = x([1:n-1])
y(1) = x(n);
 
endfunction
 
