function [resadf]=adf1(y,p,l,varargin)
 
// PURPOSE: carry out augmented Dickey-Fuller tests on a
// vector
// ------------------------------------------------------------
// REFERENCES: Said and Dickey (1984), "Testing for Unit Roots
// in Autoregressive Moving Average Models of Unknown Order",
// Biometrika, Volume 71, pp. 599-607.
// ------------------------------------------------------------
// INPUT:
// * y = a(n x 1) vector 
// * p = order of time polynomial in the null-hypothesis
//   . p = -1, no deterministic part
//   . p =  0, for constant term
//   . p =  1, for constant plus time-trend
//   . p >  1, for higher order polynomial
// * l = # of lags of the ADF test
// * varargin = optional arguments which can be:
//  - 'noprint'if the user doesn't want to print the results of
//     the regression
//  - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// resadf = a results tlist with
//   . resadf('meth')  = 'adf'
//   . resadf('y')     = y data vector of the auxiliary
//     regression
//   . resadf('x')     = x data matrix of the auxiliary
//     regression
//   . resadf('nobs')  = # observations
//   . resadf('nvar')  = # variables
//   . resadf('beta')  = bhat
//   . resadf('yhat')  = yhat
//   . resadf('resid') = residuals of the auxiliary regression
//   . resadf('vcovar') = estimated variance-covariance matrix of
//     beta
//   . resadf('sige')  = estimated variance of the residuals
//   . resadf('sigu')  = sum of squared residuals
//   . resadf('ser')  = standard error of the regression
//   . resadf('tstat') = t-stats
//   . resadf('pvalue') = pvalue of the betas
//   . resadf('dw')    = Durbin-Watson Statistic
//   . resadf('condindex') = multicolinearity cond index
//   . resadf('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . resadf('rsqr')  = rsquared
//   . resadf('rbar')  = rbar-squared
//   . resadf('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . resadf('pvaluef') = its significance level
//   . resadf('dropna') = boolean indicating if NAs have
//     been dropped
//   . resadf('namey') = name of the y variable of the auxiliary
//     regression
//   . resadf('namex') = name of the x variables of the auxiliary
//     regression
//   . resadf('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . resadf('like') = log-likelihood of the regression
//   . resadf('1% level') = 1% critical level
//   . resadf('5% level') = 5% critical level
//   . resadf('10% level') = 10% critical level
//   . resadf('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . resadf('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted to scilab from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// and Modeled after a similar Gauss routine by
// Sam Ouliaris, in a package called COINT
 
   
dx=tdiff(y,1)
dxk=dx
depend= dx(l+2:$);
z = y(l+1:$-1)
for k=1:l
   z = [z dxk(l-k+2:$-k)];
end
 
if p>(-1) then
   z = [z,ptrend(p,size(z,1))];
end
 
resadf = ols2(depend,z)

crit=cheunglai_crit(resadf('nobs')+l+1,p,l)
resadf(1)($+1) = '1% level'
resadf(1)($+1) = '5% level'
resadf(1)($+1) = '10% level'
resadf('1% level') = crit(3)
resadf('5% level') = crit(2)
resadf('10% level') = crit(1)
  
endfunction
