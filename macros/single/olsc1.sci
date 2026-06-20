function rolsc=olsc1(y,x,maxit,crit)
 
// PURPOSE: compute Cochrane-Orcutt ols Regression for AR1
// errors; low level function where variables are already in a
// matrix form
// ------------------------------------------------------------
// INPUT:
// * y = a real (n,1) vector or a
// * x = a real (n,k) matrix
// * maxit = a scalar, the maximum # of ietrations authorized
// * crit = a scalar, the convergence criterion
// ------------------------------------------------------------
// OUTPUT:
// rolsc = a tlist with
//   . rolsc('meth')  = 'Cochrane-Orcutt'
//   . rolsc('y')     = y data vector
//   . rolsc('x')     = x data matrix
//   . rolsc('nobs')  = nobs
//   . rolsc('nvar')  = nvars
//   . rolsc('beta')  = bhat
//   . rolsc('yhat')  = yhat
//   . rolsc('resid') = residuals
//   . rolsc('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolsc('sige')  = estimated variance of the residuals
//   . rolsc('sige')  = estimated variance of the residuals
//   . rolsc('ser')  = standard error of the regression
//   . rolsc('tstat') = t-stats
//   . rolsc('pvalue') = pvalue of the betas
//   . rolsc('dw')    = Durbin-Watson Statistic
//   . rolsc('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rolsc('rsqr')  = rsquared
//   . rolsc('rbar')  = rbar-squared
//   . rolsc('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rolsc('pvaluef') = its significance level
//   . rolsc('prescte') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rolsc('rho') = the autocorrelation coefficient of the
//     residuals
//   . rolsc('trho') = its T-stat
//   . rolsc('iterout') = a (niter x 3) matrix giving for each
//     iteration the estimated rho, the convergence criterion
//     and its number
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[rho,bet,iterout]=olsc0(y,x,maxit,crit)
[nobs, nvar]=size(x)
 
// after convergence produce a final set of estimates using
// rho-value
ystar=y(2:nobs)-rho*y(1:nobs-1)
xstar=x(2:nobs,:)-rho*x(1:nobs-1,:)
 
rolsc = ols2(ystar,xstar);
rolsc('meth') = 'Cochrane-Orcutt'
 
rolsc(1)($+1)='rho'
rolsc('rho')=rho
rolsc(1)($+1)='iter'
rolsc('iter')=iterout
// compute t-statistic for rho
u=y-x*bet
u_l1=u(1:nobs-1)
varrho = rolsc('sige')/(u_l1'*u_l1)
trho=rho/sqrt(varrho)
rolsc(1)($+1)='trho'
rolsc('trho')=trho
 
endfunction
