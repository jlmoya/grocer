function [rols]=olspec1(y,x,grocer_names,grocer_ltest,test_default)
 
// PURPOSE: perform ordinary least-squares and standard
// specification test (Chow in-sample stability tests computed
// at 50% and 90% of the sample; Doornik and Hansen normality
// test; heteroskedasticity test called xi² by D.F. Hendry;
// AutoRegressive Lagrange multiplier tests at order 4) or
// any tests given by the user
// ------------------------------------------------------------
// INPUT:
// * y = a (n x 1) vector
// * x = a (n x k) vector
// * grocer_names = a tlist, typed 'names' with:
//   grocer_anmes('name_foo') =  a string, the name that
//   will be given in the corresponding test in the results
//   displayed
// * grocer_ltest = a string, 'test=xxx' where xxx collects
//   the names of the specification tests performed
//   (for instance 'test=predfailin(0.5),predfailin(0.9),
//   doornhans,arlm(4),hetero_sq')
// * test_default = the testing function that will be used by
//   default
// ------------------------------------------------------------
// OUTPUT:
// rols = a results tlist with
//   . rols('meth')  = 'ols'
//   . rols('y')     = y data vector
//   . rols('x')     = x data matrix
//   . rols('nobs')  = # observations
//   . rols('nvar')  = # variables
//   . rols('beta')  = bhat
//   . rols('yhat')  = yhat
//   . rols('resid') = residuals
//   . rols('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rols('sige')  = estimated variance of the residuals
//   . rols('sigu')  = sum of squared residuals
//   . rols('ser')  = standard error of the regression
//   . rols('tstat') = t-stats
//   . rols('pvalue') = pvalue of the betas
//   . rols('dw')    = Durbin-Watson Statistic
//   . rols('condindex') = multicolinearity cond index
//   . rols('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rols('like') = log-likelihood of the regression
//   . rols('rsqr')  = rsquared
//   . rols('rbar')  = rbar-squared
//   . rols('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rols('pvaluef') = its significance level
//   . rols('name_test') = the names of the specification
//   . rols('spec_test') = a matrix with the values of the
//     statistics of the specification tests in column 1 and
//     the corresponding p-values in column 2
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nobs,nvar] = size(x)
 
// provides the results from the regression of the vector y
// on the vector x
rols=ols2(y,x)
 
[test_func,m2prt_test,nvarmax]=auto_test(grocer_names,grocer_ltest,nobs,nvar,test_default)
[val,p]=test_func(rols)
rols(1)($+1) = 'name_test'
rols('name_test') = m2prt_test
rols(1)($+1) = 'spec_test'
rols('spec_test')=[val p]
 
 
endfunction
