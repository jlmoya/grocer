function [P,lnL] = multilogit_lik(y,x,b,d)
 
// PURPOSE: Computes value of log likelihood function
// for multinomial logit regression
//-----------------------------------------------------
// INPUT:
// * y = (nobs x 1) dependent variable vector
// * x = (nobs x m) explanatory variables matrix
// * b = (m x 1) parameter vector
// * d = (nobs x (ncat-1)) matrix
//   with: d(:,i)=1 if y = i+1 th category
//               =0 if y ~= i+1 th category
//-----------------------------------------------------
// OUTPUT:
// - P = (k-1 x 1) vector of probabilities of states
//   2 to k
// - lnL = log-likelihood
//-----------------------------------------------------
 
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
// translated an adapted from a matlab program written by:
// written by:
// Simon D. Woodcock
// CISER / Economics
// Cornell University
// Ithaca, NY
// sdw9@cornell.edu
 
[nvar,ncat] = size(b);
[nobs,junk] = size(x);
P=ones(nobs,ncat)
xb =x*b;
e_xb = exp(xb);
sum_e_xb = sum(e_xb',"r");
for j = 1:ncat
   P(:,j) = e_xb(:,j) ./ (1 + sum_e_xb');
end;
P_0 = ones(nobs,1) - sum(P,'c')
p = [P_0,P];
d_0 = (y == min(y))
d = [d_0,d];
lnp = log(p);
contribution = d .*lnp;
c_0 = sum(y == 0);
lnL = sum(contribution)
 
endfunction
