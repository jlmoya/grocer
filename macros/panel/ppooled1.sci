function res=ppooled1(y,x)
 
// PURPOSE: performs Pooled Least Squares for Panel Data
// (for balanced or unbalanced data)
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')  = 'panel pooled'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = nobs
//   . res('nvar')  = nvars
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sige')  = estimated variance of the residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
// ------------------------------------------------------------
// NOTE:
// the constant -if any- must be included in the matrix x
// ------------------------------------------------------------
// copyright Eric Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
res=ols2(y,x)
res('meth')='panel pooled'
// suppress dw which is meaningless
res(1)(16)=[]
res(16)=null()
 
endfunction
