function [g2,bic] = mctest(d)
 
// PURPOSE: function called by raftery1 function
// ------------------------------------------------------------
// INPUT:
// * d = a (n x 1) vector of booleans
// ------------------------------------------------------------
// OUTPUT:
// * g2 = a scalar, the value of the log-likelihood
// * bic = a scalar, the value of the Scharz criterion
// ------------------------------------------------------------
// REFERENCES: Geweke (1992), 'Evaluating the accuracy of
// sampling-based approaches to the calculation of posterior
// moments', in J.O. Berger,J.M. Bernardo, A.P. Dawid, and
// A.F.M. Smith (eds.) Proceedings of the Fourth Valencia
// International Meeting on Bayesian Statistics, pp. 169-194,
// Oxford University Press
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
// translated and widely adapted from a Matlab program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
// NOTE: Matlab code draws heavily on MATLAB programs written by
// Siddartha Chib available at: www.econ.umn.edu/~bacc
 
n=size(d,1)
m1 = zeros(2,2);
m2 = zeros(2,2);
g2 = 0;
bic = 0;
// ED 2014: for the sake of speed, I have vetorized the original code
dnum=bool2s(d)
dnum1=dnum(1:$-2)
dnum2=dnum(2:$-1)
dnum3=dnum(3:$)
 
m1(1,1)=sum((1-dnum1).*(1-dnum2).*(1-dnum3))
m1(2,1)=sum(dnum1.*(1-dnum2).*(1-dnum3))
m1(1,2)=sum((1-dnum1).*dnum2.*(1-dnum3))
m1(2,2)=sum(dnum1.*dnum2.*(1-dnum3))
 
m2(1,1)=sum((1-dnum1).*(1-dnum2).*dnum3)
m2(2,1)=sum(dnum1.*(1-dnum2).*dnum3)
m2(1,2)=sum((1-dnum1).*dnum2.*dnum3)
m2(2,2)=sum(dnum1.*dnum2.*dnum3)
 
t=m1+m2
t2=ones(2,1) .*. sum(m1,1);
t3=ones(2,1) .*. t(1,:)
t4=ones(2,1) .*. t(2,:)
fitted1=(t .* t2)./(t3+t4);
t2b=ones(2,1) .*. sum(m2,1);
fitted2=(t .* t2b)./(t3+t4);
g2=sum(log(m1(m1~=0)./fitted1(m1~=0)).*m1(m1~=0))+sum(log(m2(m2~=0)./fitted2(m2~=0)).*m2(m2~=0))
g2 = g2*2;
bic = g2-log(n-2)*2;
 
endfunction
