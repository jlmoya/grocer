function [like]=pr_like(b,y,x)
 
// PURPOSE: evaluate probit log-likelihood
//-----------------------------------------------------
// USAGE:    like = pr_like(b,y,x,flag)
// where:     b = parameter vector (k x 1)
//            y = dependent variable vector (n x 1)
//            x = explanatory variables matrix (n x m)
//-----------------------------------------------------
// NOTE: this function returns a scalar
//-----------------------------------------------------
// SEE also: hessian, gradnt, gradt
//-----------------------------------------------------
// REFERENCES: Green, 1997 page 883
//-----------------------------------------------------
 
// written by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
// error check
if nargin~=3 then
  error('wrong # of arguments to pr_like');
end
[m,junk] = size(b);
if junk~=1 then
  error('pr_like: requires a column vector');
end
 
nobs=size(y,1)
i = ones(nobs,1);
 
cdf = cdfnor("PQ",x*b,zeros(nobs,1),ones(nobs,1));
 
tmp = matrix(find(cdf<=0),1,-1);
[n1,n2] = size(tmp);
if n1~=0 then
  cdf(tmp,1) = .00001*ones(max(size(tmp)),1);
end
 
tmp = matrix(find(cdf>=1),1,-1);
[n1,n2] = size(tmp);
if n1~=0 then
  cdf(tmp,1) = .99999*ones(max(size(tmp)),1);
end
 
 
out = y .* log(cdf)+(i-y) .* log(i-cdf);
 
like = sum(out);
 
 
endfunction
