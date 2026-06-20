function [nburn,nprec,kthin,irl,kind,nmin,ndraws] = raftery1(runs,q,r,s)
 
// PURPOSE: calculates the # of draws needed in MCMC to estimate
//    the posterior cdf of the q-quantile
//    to within +/- r accuracy with probability s
// ------------------------------------------------------------
// INPUT:
// * runs = draws from the sampler (= ndraws x nvar matrix)
// * q = quantile of the quantity of interest
// * r = level of precision desired
// * s = probability associated with r
// ------------------------------------------------------------
// OUTPUT:
// * nburn = number of draws required for burn-in (variable i)
// * nprec = number of draws required to achieve r precision
// * kthin = skip parameter for 1st-order Markov chain
// * irl   = I-statistic from Raftery and Lewis (1992)
// * kind  = skip parameter sufficient to get independence chain
// * nmin  = # draws if the chain is white noise
// * ndraws    = # of draws in draws input matrix
// ---------------------------------------------------------------------
// NOTES (by James LeSage):   Example values of q, r, s:
//     0.025, 0.005,  0.95 (for a long-tailed distribution)
//     0.025, 0.0125, 0.95 (for a short-tailed distribution);
//     0.5, 0.05, 0.95;  0.975, 0.005, 0.95;  etc.
//  - The result is quite sensitive to r, being proportional to the
//  inverse of r^2.
//  - For epsilon, we have always used 0.001.  It seems that the result
//  is fairly insensitive to a change of even an order of magnitude in
//  epsilon.
//  - One way to use the program is to run it for several specifications
//  of r, s and epsilon and vectors q on the same data set.  When one
//  is sure that the distribution is fairly short-tailed, such as when
//  q=0.025, then r=0.0125 seems sufficient.  However, if one is not
//  prepared to assume this, safety seems to require a smaller value of
//  r, such as 0.005.
//  - The program takes as input the name of a file containing an initial
//  run from a MCMC sampler.  If the MCMC iterates are independent,
//  then the minimum number required to achieve the specified accuracy
//  is about $\Phi^(-1).entries (\frac(1).entries(2).entries(1+s))^2 q(1-q)/r^2$ and this would
//  be a reasonable number to run first.
//  When q=0.025, r=0.005 and s=0.95, this number is 3,748;
//  when q=0.025, r=0.0125 and s=0.95, it is 600.
// ---------------------------------------------------------------------
// REFERENCES: Raftery, A.E.  and Lewis, S.M.  (1992).  How many iterations
// in the  Gibbs sampler?  In Bayesian Statistics, Vol.  4 (J.M.  Bernardo,
// J.O.   Berger, A.P.  Dawid and A.F.M.  Smith, eds.).  Oxford, U.K.: Oxford
// University Press, 763-773.
// ----------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
// NOTE: this is a translation of FORTRAN code
//       (which is why it looks so bad)
 
ndraws=size(runs,'*')
if q > 0 then
   cutpt = empquant(runs,q);
   work =(runs <= cutpt);
else
   q = 0;
   i1 = find(runs==0);
   i2 = find(runs==1);
   ct1 = size(i1);  ct2 = size(i2);
   if (ct1+ct2)~=n then
      error("raftery needs 0s and 1s in runs");
   end;
   work = runs;
   q = sum(runs);
   q = q/ndraws;
end; // end of if;
 
kthin = 1;
bic = 1;
epss = 0.001;
while bic>0
   tmp=work(1:kthin:ndraws)
   [g2,bic] = mctest(tmp);
   kthin = kthin+1;
end; // end of while
kthin = kthin-1;
 
[alpha,bet] = mcest(tmp);
kmind = kthin;
 
[g2,bic] = indtest(tmp);
while bic > 0
   tmp=work(1:kmind:ndraws)
   [g2,bic] = indtest(tmp);
   kmind = kmind+1;
end;
 
psum = alpha+bet;
tmp1 = log((psum*epss)/max(alpha,bet))/log(abs(1-psum))
nburn = fix((tmp1+1)*kthin);
phi = ppnd((s+1)/2);
tmp2 = (2-psum)*alpha*bet*phi^2/((psum^3)*(r^2));
nprec = fix(tmp2+1)*kthin;
nmin = fix((1-q)*q*phi^2/r^2+1);
irl = (nburn + nprec)/nmin;
kind = max(fix(irl+1),kmind);
ndraws = nburn+nprec;
 
endfunction
