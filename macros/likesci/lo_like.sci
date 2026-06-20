function [out]=lo_like(b,y,x)
 
// PURPOSE: evaluate logit log-likelihood
// ------------------------------------------------------------
// INPUT:
// * b = parameter vector (k x 1)
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x m)
// ------------------------------------------------------------
// OUTPUT:
// -log(pseudo-likelihood)
// ------------------------------------------------------------
// NOTE: this function returns a scalar
//       k ~= m because we may have additional parameters
//           in addition to the m bhat's (e.g. sigma)
//-----------------------------------------------------
// REFERENCES: Green, 1997 page 883
//-----------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
cte = ones(size(y,1),1);
cdf = cte ./ (cte+exp(-x*b));
tmp = find(cdf<=0)';
[n1,n2] = size(tmp);
if n1~=0 then
  cdf(tmp) = .00001
end
 
tmp = find(cdf>=1)';
[n1,n2] = size(tmp);
if n1~=0 then
  cdf(tmp) = .99999
end
 
like =  y .* log(cdf)+(cte-y) .* log(cte-cdf);
 
out = sum(like);
endfunction
