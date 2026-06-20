function [flag,lambda,dt,lr1,lr2,pi,s00,lambda2]=johansen_eigen(dx,exo_st,exo_lt)
 
// PURPOSE: calculate eigen values of a johansen procdure
// ------------------------------------------------------------
// * References: Johansen (1988), 'Statistical Analysis of
// Co-integration vectors', Journal of Economic Dynamics and
// Control, 12, pp. 231-254.
//------------------------------------------------------------
// INPUT:
// * dx = a (nobs x ny) vector of differentiated endogenous
//   variables
// * exo_st = a (nobs x (ny*k+nexo_st) vector of exogenous
//   variables in the short term dynamic (= the lagged
//   differentiated endogenous variables + the exogenous
//   variables outside the cointegration vectors)
// * exo_lt = a (nobs x (ny+nexo_lt) vector of lagged
//   endogenous variables (in level) and exogenous
//   variables incorporated to the cointegration vectors
// ------------------------------------------------------------
// OUTPUT:
// * flag = a flag ('Ok'/'not OK') indicating whether the
//   problem is well specified
// * lambda = a (ny x 1) vector of eigenvalues of the reduced
//   rank regression
// * dt = a (nobs x ny) matrix, each column being a
//   cointegration vector
// * lr1 = a (ny x 1) vector of trace tests statistics
// * lr2 = a (ny x 1) vector of lambda max
// * pi = a ((ny+nexo_lt) x ny) matrix of combined effects of
//   the variables in the cointegration relations on the
//   differentiated endogenous variables
// * s00 = a (ny x ny) matrix, equal to the variance of the
//   residuals of the regression of dx on exo_st
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// (with bug fixes and corrections by Adina Enache)
 
[T,m]=size(dx)
m=min(m,size(exo_lt,2))
 
flag='Ok'
// set output for the case when the problem is badly specified
dt=[]
lr1 = []
lr2 = []
 
if isempty(exo_st) then
   r0t=dx
   r1t=exo_lt
else
   r0t = dx-exo_st*ols0(dx,exo_st)
   r1t = exo_lt-exo_st*ols0(exo_lt,exo_st)
end
pi=ols0(r0t,r1t)
s11 = r1t'*r1t/T
s10 = r1t'*r0t/T
s00 = r0t'*r0t/T
 
sig = pinv(s11)*s10*pinv(s00)*s10';
[du,lambda]=spec(sig)
[lambda,ind_lambda]=gsort(real(diag(lambda)),'r','d')
lambda=lambda(1:m)
[junk,lambda2]=spec(du'*s11*du)
lambda2=real(diag(lambda2))
 
if lambda(1) > 1 | lambda(m) < 1E-8 | min(lambda2) < 1E-8 then
   flag='not OK'
else
   // Normalize the eigen vectors such that (du's11*du) = I
   dt = du*inv(chol(du'*s11*du));
   dt=dt(:,ind_lambda(1:m))
 
   // Compute the trace and max eigenvalue statistics
   lr1=-T*cumsum(log(1-lambda(m:-1:1)))
   lr1=lr1(m:-1:1)
   lr2=-T*log(1-lambda)
end
 
endfunction
