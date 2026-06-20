function [b,yhat,tstat,pvalue,resid,covb,like1,nobs,nvar]=probit1(y,x,b0)
 
// PURPOSE: computes Probit Regression
// ------------------------------------------------------------
// References: Arturo Estrella (1998) 'A new measure of fit
// for equations with dichotmous dependent variable', JBES,
// Vol. 16, #2, April, 1998.
// ------------------------------------------------------------
// INPUT:
// * namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
//  vector between quotes; all values should be 0 or 1
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'maxit=xx' if the user wants to set the
//     maximum # of iterations to xx (default=100)
//   . the string 'tol=xx' if the user wants to set the
//     convergence criterion to xx (default=1e-6)
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// * b = the estimated parameters
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
 
[nobs,nvar] = size(x);
 
[like1,b]=optim(probit_like,b0)
while like1 == 0 then
// the problems has in fact diverged, with very big values
// of the parameters
   lambda=grand(1,1,'def')
//   b00=lambda*b0+(1-lambda)*grand(nvar,1,'nor',0,0.5)/max(abs(x*b0));
   b00=lambda*b0
   [like1,b]=optim(probit_like,b00)
end
// compute Hessian for inferences
q = 2*y-1;
// see page 883 Green, 1997
xxb = x*b;
pdf = norm_pdf(q .* xxb);
cdf = max(cdfnor("PQ",q .* xxb,zeros(nobs,1),ones(nobs,1)),sqrt(%eps));
lambda = q .* pdf ./ cdf;
H = zeros(nvar,nvar);
for i = 1:nobs
  xb = x(i,:)*b;
  xp = x(i,:)';
  H = H-lambda(i,1)*(lambda(i,1)+xb)*(xp*x(i,:));
end
 
// now compute regression results
covb = -inv(H);
stdb = sqrt(diag(covb));
tstat = b ./ stdb
 
df=nobs-nvar
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
// fitted probabilities
yhat = cdfnor("PQ",x*b,zeros(nobs,1),ones(nobs,1))
resid = y-yhat
like1=-like1
 
endfunction
