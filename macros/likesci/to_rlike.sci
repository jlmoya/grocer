function [like]=to_rlike(b,y,x,a)
 
// PURPOSE: evaluate tobit log-likelihood for right-censoring
// case (y <= a is censored)
// ------------------------------------------------------------
// INPUT:
// * b = parameter vector (k x 1)
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x m)
// * a = left-censoring point (default = 0)
// OUTPUT:
// a scalar equal to the negative of the log-likelihood
// function
// ------------------------------------------------------------
// NOTE: k ~= m because we may have additional parameters in
// addition to the m bhat's (e.g. sigma)
//-----------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// tanslated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
 
// error check
if nargin==4 then
  aterm = a;
elseif nargin==3 then
  aterm = 0;
else
  error('wrong # of arguments to to_rlike');
end
h = .000001;
// avoid sigma = 0
[m,junk] = size(b);
bet = b(1:m-1);
// pull out bhat
sigma = max([b(m),h]);
// pull out sigma
xb = x*bet;
llf1 = -(y-xb).^2/(2*sigma)-.5*log(2*%pi*sigma);
xbs = -(aterm-xb) ./ sqrt(sigma);
cdf = .5*(1+erf(xbs ./ sqrt(2)));
llf2 = log(h+cdf);
llf = bool2s(y<aterm) .* llf1+bool2s(y>=aterm) .* llf2;
 
like = -sum(llf);
// scalar result
 
endfunction
