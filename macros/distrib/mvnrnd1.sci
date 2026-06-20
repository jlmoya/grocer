function [r] = mvnrnd1(mu,sigma,cases,tol) 


// modified matlab code, lets almost singular matricies, that may be
// generated at some draws, go through

//MVNRND Random matrices from the multivariate normal distribution.
//   R = MVNRND(MU,SIGMA,CASES) returns a matrix of random numbers chosen   
//   from the multivariate normal distribution with mean vector, MU, and 
//   covariance matrix, SIGMA. CASES is the number of rows in R.
// 
//   SIGMA is a symmetric positive semi-definite matrix with size equal
//   to the length of MU.

//   B.A. Jones 6-30-94
//   Copyright 1993-2000 The MathWorks, Inc. 
//   $Revision: 2.9 $  $Date: 2000/06/02 16:54:14 $

D=spec(sigma)
D = real(D);

tol= max(D) * size(D,1)* tol
if or(D <= tol) then
   [U,junk] = spec(sigma);
   // it would seem more efficient to calculate the eigenvectors at the 
   // same time that the eigenvalues
   // but calculating only the eigenvealues is more rapid
   // so when there are only a few cases when sigma is ill-conditionned
   // the current programming is more efficient 
   t = (D > tol);
   D = D(t);
   T = U(:,t)*diag(sqrt(D));
   mu=mu .*. ones(1,cases)
   r=T*grand(size(T,2),cases,'nor',0,1)+mu

else
   r=grand(cases,'mn',mu,sigma);

end;


endfunction
