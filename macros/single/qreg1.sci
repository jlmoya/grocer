function [r] = qreg1(y,x,tau,w,algo,maxit,eps,big,sigma);
 
// PURPOSE: provides quantile regression on matrices
// ------------------------------------------------------------
// INPUT:
// * y = a (nobs x 1) real vector of endogenous variable
// * x = a (nobs x k) real matrix of exogenous variables
// * tau = a (q x 1) vector of quantiles to be estimated
// * w = 0 or a (nobs x 1) vector of observation weights
// * algo = a string, the name of the algorithm ('qreg_solvelp1'
//          or 'linpro')
// * maxit = an integer, the maximum number of iterations
// * eps = a real, tolerance value for convergence
// * big = a big real, the number used to remove the residuals
//     of the wrong sign
// * sigma = a scalar, < 1, the scaling factor that
//     determines how close the corrector step is allowed
//     to come to the boundary of the constraint set in the
//     interior point method
// ------------------------------------------------------------
// OUTPUT:
// r = a results tlist with:
// - r('meth') = 'quantile'
// - r('y') = y data vector
// - r('x') = x data matrix
// - r('tau') = vector of quantiles to be estimated
// - r('weights') = 0 or a (nobs x 1) vector of observation
//      weights
// - r('nobs')  = # observations
// - r('nvar')  = # variables
// - r('beta')  = (nvar x q) matrix of quantile estimations
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_ieee=ieee();
ieee(2);
 
[n,k] = size(x);
tau=vec2col(tau);
m = size(tau,1);
 
if w ~= 0 then
   y=w .* y
   x= (w .*. ones(1,k)) .* x
end;
 
bet = zeros(k,m);
u_plus = zeros(n,m);
u_minus = zeros(n,m);
 
for i=1:m
   sv = (1-tau(i))*ones(n,1);
   if algo == 'qreg_solve' then
      bet(:,i) = -qreg_solve(-y,x',x'*sv,ones(n,1),sv,maxit,eps,big,sigma);
   else
      [junk,lagr]=linpro(-y,x',x'*sv,zeros(n,1),ones(n,1),2,sv)
      bet(:,i)= lagr($-k+1:$)
   end
   u = y - x*bet(:,i);
   u_minus(:,i)=-u .* bool2s(u<0)
   u_plus(:,i) = u + u_minus(:,i);
 
end;
 
r=tlist(['results';'meth';'y';'x';'tau';'weights';'nobs';'nvar';'beta'],...
'quantile',y,x,tau,w,n,k,bet)
 
ieee(grocer_ieee);
 
endfunction;
