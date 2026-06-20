function [alpha,bet] = mcest(d)
 
// PURPOSE: function called by raftery1 function
// ------------------------------------------------------------
// INPUT:
// * d = a (n x 1) vector of booleans
// ------------------------------------------------------------
// OUTPUT:
// * alpha = a scalar
// * beta = a scalar
// ------------------------------------------------
// REFERENCES: Geweke (1992), `Evaluating the accuracy of sampling-based
// approaches to the calculation of posterior moments'', in J.O. Berger,
// J.M. Bernardo, A.P. Dawid, and A.F.M. Smith (eds.) Proceedings of
// the Fourth Valencia International Meeting on Bayesian Statistics,
// pp. 169-194, Oxford University Press
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
// translated and widely adapted from a Matlab program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
// NOTE: the original Matlab code draws heavily on MATLAB programs
//  written by Siddartha Chib available at: www.econ.umn.edu/~bacc
 
t = zeros(2,2);
t = zeros(2,2);
// ED 2014: for the sake of speed, I have vetorized the original code
dnum=bool2s(d);
dnum1=dnum(1:$-1);
dnum2=dnum(2:$);
t(1,1)=sum((1-dnum1).*(1-dnum2))
t(2,1)=sum(dnum1.*(1-dnum2))
t(1,2)=sum((1-dnum1).*dnum2)
t(2,2)=sum(dnum1.*dnum2)
 
alpha = t(1,2)/(t(1,1)+t(1,2));
bet = t(2,1)/(t(2,1)+t(2,2));
 
endfunction
