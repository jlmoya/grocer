function [resadf]=adf(grocer_namey,grocer_p,grocer_l,varargin)
 
// PURPOSE: carry out augmented Dickey-Fuller tests on a
// time-series vector
// ------------------------------------------------------------
// REFERENCES: Said and Dickey (1984), "Testing for Unit Roots
// in Autoregressive Moving Average Models of Unknown Order",
// Biometrika, Volume 71, pp. 599-607.
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * grocer_p = order of time polynomial in the null-hypothesis
//   . grocer_p = -1, no deterministic part
//   . grocer_p =  0, for constant term
//   . grocer_p =  1, for constant plus time-trend
//   . grocer_p >  1, for higher order polynomial
// * grocer_l = # of lags of the ADF test
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
 
 
[nargout,nargin] = argn(0)
if nargin < 3 then
   error('nargin should be at least 3')
end
 
[grocer_dropna,grocer_prt]=vararg2dropnaprt(varargin(:))

[grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb,grocer_nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
 
grocer_namexos=[]
if grocer_p < (-1) then
   error('p less than -1 in adf')
end
if grocer_p >= 0 then
   prescte = %t
   grocer_namexos=[grocer_namexos ; 'cte']
end
if grocer_p == 1 then
   grocer_namexos=[grocer_namexos ; 't']
end
 
if (size(grocer_y,1)-2*grocer_l+1)<1 then
   error('nlags too large in adf, negative dof');
end
 
dx=tdiff(grocer_y,1)
dxk=dx
depend= dx(grocer_l+2:$);
z = grocer_y(grocer_l+1:$-1)
for k=1:grocer_l
   z = [z dxk(grocer_l-k+2:$-k)];
end
 
if grocer_p>(-1) then
   z = [z,ptrend(grocer_p,size(z,1))];
end
 
resadf = ols2(depend,z)
resadf(1)($+1) = 'prests'
resadf('prests') = grocer_prests
resadf(1)($+1) = 'namex'
resadf(1)($+1) = 'namey'
 
for i=grocer_l:-1:1
   grocer_namexos=['del('+grocer_namey+'(t-'+string(i)+'))' ; grocer_namexos ]
end
grocer_namexos=[grocer_namey+'(t-1)' ; grocer_namexos]
 
// change the method name
resadf('meth') = 'ADF'
 
resadf('namex')=grocer_namexos
resadf('namey')='del('+grocer_namey'+')'
resadf(1)($+1) = 'dropna'
resadf('dropna')=grocer_dropna
 
if grocer_prests then
   resadf(1)($+1)='bounds'
   [b1,fq]=date2num_fq(grocer_boundsvarb(1))
   resadf('bounds')=[num2date(b1+grocer_l+1,fq) ; grocer_boundsvarb(2)]
end
 
if grocer_dropna then
   resadf(1)($+1)='nonna'
   resadf('nonna')=nonna
end
 
crit=cheunglai_crit(resadf('nobs')+grocer_l+1,grocer_p,grocer_l)
resadf(1)($+1) = '1% level'
resadf(1)($+1) = '5% level'
resadf(1)($+1) = '10% level'
resadf('1% level') = crit(3)
resadf('5% level') = crit(2)
resadf('10% level') = crit(1)
 
if grocer_prt then
   prt_adf(resadf,%io(2))
end

printsep(%io(2))
 
endfunction
