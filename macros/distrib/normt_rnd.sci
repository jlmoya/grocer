function [result] = normt_rnd(mu,sigma2,left,right)

// PURPOSE: random draws from a normal truncated to
// (left,right) interval
// ------------------------------------------------------
// USAGE: y = normt_rnd(mu,sigma2,left,right)
// where:   mu = mean (nobs x 1)
//      sigma2 = variance (nobs x 1)
//        left = left truncation points (nobs x 1)
//       right = right truncation points (nobs x 1)
// ------------------------------------------------------
// RETURNS: y = (nobs x 1) vector
// ------------------------------------------------------
// NOTES: use y = normt_rnd(mu,sigma2,left,mu+5*sigma2)
//        to produce a left-truncated draw
//        use y = normt_rnd(mu,sigma2,mu-5*sigma2,right)
//        to produce a right-truncated draw
// ------------------------------------------------------
// SEE ALSO: normlt_rnd (left truncated draws), normrt_rnd (right truncated)
// 

// adopted from Bayes Toolbox by
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu

// For information on the Bayes Toolbox see:
// Ordinal Data Modeling by Valen Johnson and James Albert
// Springer-Verlag, New York, 1999.


[nargout,nargin]=argn(0)
if nargin~=4 then
  error("normt_rnd: wrong # of input arguments");
end;

std = sqrt(sigma2);
// Calculate bounds on probabilities
lowerProb = Phi((left-mu) ./std);
upperProb = Phi((right-mu) ./std);
// Draw uniform from within (lowerProb,upperProb)
[nr,nc] = size(mu);
u = lowerProb+(upperProb-lowerProb) .* grand(nr,nc,'def');
// Find needed quantiles
result = mu + Phiinv(u).*std

endfunction


