function lpost = bmapost_g(y,x,vin,g)
 
// PURPOSE: evaluates log marginal posterior of OLS bma model
//          (OLS Bayesian model averaging)
//-----------------------------------------------------------
// INPUTS:
// . y 		= dependent variable vector (nobs x 1)
// . x	 	= explanatory variables matrix (nobs x k)
// . vin = a 1xk vector of columns to use from x
// . g 		= g-prior
//-----------------------------------------------------------
// RETURNS: lpost = log marginal posterior, a scalar
//                  containing the log marginal
//-----------------------------------------------------------
// Fernandez,Carmen, Eduardo Ley, and Mark F. J. Steel, (2001)
// "Benchmark priors for bayesian model averaging",
// Journal of Econometrics, Volume 100, number 2, pp. 381-427.
// ----------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
x = x(:,vin)
[nobs,nvar] = size(x)
 
e=ones(nobs,1)/nobs
ys = y-(e .*. (e'*y))
	
gpond=g/(1+g)
 
xs = x - (e .*. (e'*x))
xt = [e xs]
 
[xpxi,xpxixp]=invxpx(xt)
b=xpxixp*y
res = y - xt*b
	
lpost = 0.5*nvar*log(gpond)-0.5*(nobs-1)*log((1-gpond)*(res'*res)+gpond*(ys'*ys))
 
endfunction
