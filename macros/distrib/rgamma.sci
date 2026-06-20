function [x]=rgamma(nn,a)
 
// PURPOSE: Random numbers from the gamma distribution
// ------------------------------------------------------------
// INPUT:
// * nn = [p q] = variable vector (2x1)
// * a = gamma parameter (default=0)
// ------------------------------------------------------------
// OUTPUT:
// x == (pxq) matrix containing randow draws from the gamma(a)
// distribution
// ------------------------------------------------------------
// NOTE/ The algorithm is a rejection method. The logarithm of
// the gamma variable is simulated by dominating it with a
// double exponential. The proof is easy since the log density
// is convex!
// ------------------------------------------------------------
// GNU Public Licence Copyright (c) Anders Holtsberg 10-05-2000
// Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by JP LeSage,
// jlesage@spatial-econometrics.com
// and adapted to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
 
if or(a<=0) then
  error('Parameter a is wrong');
end
 
n = prod(nn);
 
if is_scalar(nn) then
  nn = [nn ; 1]
end
 
y0 = log(a)-1/sqrt(a);
c = a-exp(y0);
m = ceil(n*(1.7+.6*bool2s(min(min(a,'r'))<2)));
 
y = log(rand(m,1,'u')) .* sign(rand(m,1,'u')-.5)/c+log(a);
f = a*y-exp(y)-(a*y0-exp(y0));
g = c*(abs(y0-log(a))-abs(y-log(a)));
reject = (log(rand(m,1,'u'))+g)>f;
y(reject) = matrix([],-1,1)
 
if max(size(y))>=n then
  x = exp(y(1:n));
else
  x = [exp(y);rgamma(n-max(size(y)),a)];
end
x = matrix(x,n/nn(2),nn(2));
endfunction
