function resultsr = raftery(runs,q,r,s)
 
// PURPOSE: perform Raftery and Lewis (1991) convergence diagnostic:
//    calculates the # of draws needed in MCMC to estimate
//    the posterior cdf of the q-quantile
//    to within +/- r accuracy with probability s
// ------------------------------------------------------------
// INPUT:
// * runs = draws from the sampler (= ndraws x nvar matrix)
// * q = quantile of the quantity of interest
// * r = level of precision desired
// * s = required probability of attaining the required
//       accuracy r
// ------------------------------------------------------------
// OUTPUT:
// resultsr = results tlist with:
// * result('meth')  = 'raftery diagnostic'
// * result('quantile')  = quantile of the quantity of interest
// * result('accuracy')  = level of precision desired
// * result('probability for accuracy')  = required probability
//   of attaining the required accuracy r
// * result('# of draws for burn-in') = number of draws required
//   for burn-in
// * result('# of draws for required accuracy') = number of
//   draws required to achieve r precision
// * result('skip parameter for 1st-order Markov chain') = skip
//   parameter for 1st-order Markov chain
// * result('I-statistic')  = I-statistic from Raftery and
//   Lewis (1992)
// * result('skip parameter to get independence')  = skip
//   parameter sufficient to get independence chain
// * result('skip parameter to get independence'') = # draws if
//   the chain is white noise
// ---------------------------------------------------------------------
// NOTES:   Example values of q, r, s:
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
// University Press, 763-773.   This paper is available via the World Wide
// Web by linking to URL
// http://www.stat.washington.edu/tech.reports/pub/tech.reports % and then
// selecting the """"How Many Iterations in the Gibbs Sampler"""" % link.
//  This paper is also available via regular ftp using the following commands:
//    ftp ftp.stat.washington.edu (or 128.95.17.34)                                                                                                                                                   *
//  Raftery, A.E. and Lewis, S.M. (1992).  One long run with diagnos-
//  tics: Implementation strategies for Markov chain Monte Carlo.
//  Statistical Science, Vol. 7, 493-497.                                                                                                    *
//  Raftery, A.E. and Lewis, S.M. (1995).  The number of iterations,
//  convergence diagnostics and generic Metropolis algorithms.  In
//  Practical Markov Chain Monte Carlo (W.R. Gilks, D.J. Spiegelhalter
//  and S. Richardson, eds.). London, U.K.: Chapman and Hall.
//  This paper is available via the World Wide Web by linking to URL
//    http://www.stat.washington.edu/tech.reports/pub/tech.reports
//  and then selecting the """"The Number of Iterations, Convergence
//  Diagnostics and Generic Metropolis Algorithms"""" link.
//  This paper is also available via ftp.stat.washington.edu (or 128.95.17.34)
// ----------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
// translated and somehow adapted from a program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
 
size_data=size(data)
 
if size(size_data) > 3 then
    error('dimensions of input data ('+string(size(size_data))+') is too big')
elseif size(size_data) == 2 then
    size_data=[1 , size_data]
end
 
nburn=%nan*ones(size_data(1),size_data(2))
nprec=%nan*ones(size_data(1),size_data(2))
kthin=%nan*ones(size_data(1),size_data(2))
irl=%nan*ones(size_data(1),size_data(2))
kind=%nan*ones(size_data(1),size_data(2))
nmin=%nan*ones(size_data(1),size_data(2))
 
for i=1:size_data(1)
   for j=1:size_data(2)
      diff_data=sum(abs(data(i,j,:)-data(i,j,1)))
      if diff_data ~= 0 then
         [nburn_ij,nprec_ij,kthin_ij,irl_ij,kind_ij,nmin_ij] = raftery1(squeeze(data(i,j,:)),q,r,s)
         nburn(i,j)=nburn_ij
         nprec(i,j)=nprec_ij
         kthin(i,j)=kthin_ij
         irl(i,j)=irl_ij
         kind(i,j)=kind_ij
         nmin(i,j)=nmin_ij
      end
   end
end
 
if size(size_data) == 2 then
   nburn=squeeze(nburn)
   nprec=squeeze(nprec)
   kthin=squeeze(kthin)
   irl=squeeze(irl)
   kind=squeeze(kind)
   nmin=squeeze(nmin)
end
 
resultsr=tlist(['results';'meth';'quantile';'accuracy';'probability for accuracy';...
'# of draws for burn-in';'# of draws for required accuracy';...
'skip parameter for 1st-order Markov chain';'I-statistic';...
'skip parameter to get independence';'# draws if the chain is white noise'],...
'raftery diagnostic',q,r,s,...
nburn,nprec,kthin,irl,kind,nmin)
 
endfunction
