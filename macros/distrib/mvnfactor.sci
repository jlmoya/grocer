function [T] = mvnfactor(sigma,tol) 
    
//---------------------------------------
//MVNFACTOR  Do Cholesky-like decomposition, allowing zero eigenvalues
//   SIGMA must be symmetric.  In general T is not square or triangular.


[U,D] = spec(sigma);
D = diag(D);

tol= max(D) * size(D,1)* tol
t = (D > tol);
D = D(t);
T = diag(sqrt(D)) * U(:,t)';

endfunction
