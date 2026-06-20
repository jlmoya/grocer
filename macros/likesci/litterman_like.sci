function [llike,sigma_a,bet,w,U,sqrtWi]=litterman_like(rho,Y,X,LL,C,N,evec)
 
// PURPOSE: Log-likelihood for the Litterman desaggregation
// methods
// ------------------------------------------------------------
// INPUT:
// * rho = a scalar equal to the autocorrelation of the
//   residuals
// * Y = vector of the high frequency data
// * x = (Nxk) vector of the indicators at low frequency
// * LL = a matrix of 0, 1 and -1
// * C = aggregation (N*sxN) matrix
// * N = # of low frequency data
// * evec = ones(N*s,1)
// ------------------------------------------------------------
// OUTPUT:
// * llike = minus the log Likelihood
// * sigma_a = a (NxN) matrix (the variance-covaraince matrix
//   of the residuals)
// * bet = (kx1) parameter of estimated coefficients
// * w = high frequency weights
// * U = (Nx1) vector of residuals
// * sqrtWi = a (NxN) matrix (the square root of the low
//   frequency weights)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
Aux = (I+rho*LL)*(I+LL)
w = invxpx(Aux);
// High frequency VCV matrix (without sigma_a)
W = C*w*C';
//Low frequency VCV matrix (without sigma_a)
[u,d,v]=svd(W)
sqrtWi = u* diag(evec ./ sqrt(diag(d))) *v'
wi=sqrtWi*sqrtWi
bet = ols0(sqrtWi*Y,sqrtWi*X)
// beta ML estimator
U = Y-X*bet
// Low frequency residuals
sigma_a = U'*wi*U/N
// sigma_a ML estimator
// Opposite of the log Likelihood function
llike = (N/2)*log(2*%pi*sigma_a)+1/2*log(det(W))+N/2;
endfunction
