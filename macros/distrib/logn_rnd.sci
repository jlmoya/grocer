function [r]=logn_rnd(mu,sigma,m,n)
 
// PURPOSE: random draws from the lognormal
// distribution
//---------------------------------------------------
// INPUT:
// * mu = the mean (may be a matrix)
// * sigma = the standard deviation (may be a matrix)
// * m,n = the size of r in the case of mu or sig a
//   matrix
//---------------------------------------------------
// OUTPUT:
// rnd = a matrix of random numbers from the lognormal
// distribution
// --------------------------------------------------
// SEE ALSO: logn_cdf, logn_pdf, logn_inv
//---------------------------------------------------
// NOTE: Copyright (c) 1993 by The MathWorks, Inc.
//---------------------------------------------------
// REFERENCES:
// Evans, Merran, Hastings, Nicholas and Peacock,
///   Brian, """"Statistical Distributions, Second
//    Edition"""", Wiley 1993 p. 102-105.
 
 
[nargout,nargin] = argn(0)
if nargin~=2 & nargin~=4 then
  error('Wrong # of arguments to logn_rnd');
end
 
errorcode = 0;
 
if nargin==2 then
  [murow,mucol] = size(mu);
  [sirow,sicol] = size(sigma);
  if murow==1|sirow==1 then
    m = max(murow,sirow);
  end
  if mucol==1|sicol==1 then
    n = max(mucol,sicol);
  end
end
 
if  nargin == 3 then
  error('Wrong number of arguments to logn_rnd');
end
 
 
r = exp(grand(m,n,'nor',0,1) .* sigma+mu)
 
// Return NaN if SIGMA is not positive.
 
if or(sigma<=0) then
  if prod(size(sigma)==1) then
    r = %nan*ones(rows,columns);
  else
    k = matrix(find(sigma<=0),1,-1);
    %v2=size(k)
      [rsig,csig] = find(sigma <= 0);
      for i=1:size(rsi,2)
         r(rsig(i),csig(i)) = %nan
      end
   end
end
 
endfunction
