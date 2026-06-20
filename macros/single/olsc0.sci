function [rho,bet,iterout]=olsc0(y,x,maxit,crit,msg)
 
// PURPOSE: compute Cochrane-Orcutt ols Regression for AR1
// errors; low level function where variables are already in a
// matrix form; only the final rho, beta and their successive
// values are provided
// ------------------------------------------------------------
// INPUT:
// * y = a real (n,1) vector or a
// * x = a real (n,k) matrix
// * maxit = a scalar, the maximum # of ietrations authorized
// * crit = a scalar, the convergence criterion
// * msg = a flag (if given the function does not warn if the
//   number of iterations is exceded)
// ------------------------------------------------------------
// OUTPUT:
//   . rho = the autocorrelation coefficient of the residuals
//   . bet  = estimated parameter
//   . iterout = a (niter x 3) matrix giving for each
//     iteration the estimated rho, the convergence criterion
//     and its number
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin]=argn(0)
// ----- setup parameters
converg = 1;
rho = 0;
iter = 1;
[nobs,nvar]=size(x)
[nobs2]=size(y,1)
 
// truncate 1st observation to feed the lag
xlag = x(1:nobs-1,:);
ylag = y(1:nobs-1,1);
yt = y(2:nobs,1);
xt = x(2:nobs,:);
 
// setup storage for iteration results
iterout = zeros(maxit,3);
 
while (converg>crit)&(iter<maxit) then
  // step 1, using intial rho = 0, do OLS to get bhat
  ystar = yt-rho*ylag;
  xstar = xt-rho*xlag;
  e = y-x*ols0(ystar,xstar);
 
  et = e(2:nobs,1);
  elagt = e(1:nobs-1,1);
 
  // step 2, update estimate of rho using residuals
  //         from step 1
 
  rho_last = rho;
  rho = ols0(et,elagt);
  converg = abs(rho-rho_last);
 
  iterout(iter,1) = rho;
  iterout(iter,2) = converg;
  iterout(iter,3) = iter;
 
  iter = iter+1;
 
end
// end of while loop
 
if iter==maxit & nargin < 5 then
  warning(' olsc0 did not converge in '+string(maxit)+' iterations');
end
 
bet = ols0(ystar,xstar);
param = [rho ; bet ]
 
endfunction
