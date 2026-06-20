function [g2,bic] = indtest(d)
 
 
// PURPOSE: function called by raftery.m
// ------------------------------------------------------------
// INPUT:
// * d = a (n x 1) vector of booleans
// ------------------------------------------------------------
// OUTPUT:
// * g2 = a scalar, the value of the log-likelihood
// * bic = a scalar, the value of the Scharz criterion
// ------------------------------------------------------------
// REFERENCES: Geweke (1992), `Evaluating the accuracy of sampling-based
// approaches to the calculation of posterior moments'', in J.O. Berger,
// J.M. Bernardo, A.P. Dawid, and A.F.M. Smith (eds.) Proceedings of
// the Fourth Valencia International Meeting on Bayesian Statistics,
// pp. 169-194, Oxford University Press
// Also: `Using simulation methods for Bayesian econometric models:
// Inference, development and communication'', at: www.econ.umn.edu/~bacc
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
// translated and widely adapted from a Matlab program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
// NOTE: this code draws heavily on MATLAB programs written by
// Siddartha Chib available at: www.econ.umn.edu/~bacc
 
n=size(d,1)
t = zeros(2,2);
// ED 2014: for the sake of speed, I have vetorized the original code
dnum=bool2s(d);
dnum1=dnum(1:$-1);
dnum2=dnum(2:$);
t(1,1)=sum((1-dnum1).*(1-dnum2))
t(2,1)=sum(dnum1.*(1-dnum2))
t(1,2)=sum((1-dnum1).*dnum2)
t(2,2)=sum(dnum1.*dnum2)
 
dcm1 = n-1
g2 = 0;
for i1 = 1:2
   for i2 = 1:2
      if t(i1,i2)~=0 then
         t1 = t(i1,1)+t(i1,2);
         t2 = t(1,i2)+t(2,i2);
         fitted = (t1*t2)/dcm1;
         focus = t(i1,i2);
         g2 = g2+log(focus/fitted)*focus;
    end;
  end;
end;
g2 = g2*2;
bic = g2-log(dcm1);
 
endfunction
