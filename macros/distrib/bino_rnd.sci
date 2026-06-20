function [rnd]=bino_rnd(N,p,r,c)
 
// PURPOSE: random sampling from a binomial distribution
// ------------------------------------------------------------
// INPUT:
// * N = number of trials (scalar)
// * p = the probability of success (scalar)
// * r,c = size of random sample from binominal(n,p)
// distribution (optional; default=1,1)
// ------------------------------------------------------------
// OUPTUT:
// rnd = matrix, vector or scalar of random deviates
//              equal to the number of successes in n-trials
// ------------------------------------------------------------
// NOTE:  mean = N*p, variance = N*p*(1-p)
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// converted to MATLAB by
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// and adapted (very freely !) to scilab by Eric Dubois
 
 
[nargout,nargin] = argn(0)
select nargin
case 2 then
   r=1
   c=1
case 4 then
   if r~=round(r)|c~=round(c) then
      error('r and c should be integers')
   end
else
   error('wrong number of arguments in bino_rnd')
end
 
tmp = grand(r*c,N,'def');
rnd = matrix(sum(tmp<p,2),r,c);
 
endfunction
