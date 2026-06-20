function rolsar=olsar(y,x)

// PURPOSE: computes maximum likelihood ols regression for AR1
// errors
// ------------------------------------------------------------
// INPUT:
// * y = a real (n,1) vector or a  
// * x = a real (n,k) matrix
// * varargin = any argument to optim
//---------------------------------------------------
// rolsar1 = a results tlist with
//   . rolsar('meth')  = ' ar(1) maximum likelihood'
//   . rolsar('y')     = y data vector
//   . rolsar('x')     = x data matrix
//   . rolsar('nobs')  = # observations
//   . rolsar('nvar')  = # variables
//   . rolsar('beta')  = bhat
//   . rolsar('yhat')  = yhat
//   . rolsar('resid') = residuals
//   . rolsar('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolsar('sige')  = estimated variance of the residuals
//   . rolsar('sigu')  = sum of squared residuals
//   . rolsar('ser')  = standard error of the regression
//   . rolsar('tstat') = t-stats
//   . rolsar('pvalue') = pvalue of the betas
//   . rolsar('dw')    = Durbin-Watson Statistic
//   . rolsar('condindex') = multicolinearity cond index
//   . rolsar('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rolsar('rsqr')  = rsquared
//   . rolsar('rbar')  = rbar-squared
//   . rolsar('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rolsar('pvaluef') = its significance level
//   . rolsar('rho') = estimated first order autocorrelation of residuals
//   . rolsar('trho') = its Student t
//   . rolsar('like') = log-likelihood of the regression
// --------------------------------------------------


[nobs,nvar] = size(x);
[nobs2] = size(y,1);
  
xtmp = lag(x,1);
ytmp = lag(y,1);
 
// truncate 1st observation to feed the lag
xlag = xtmp(2:nobs,:);
ylag = ytmp(2:nobs,1);
yt = y(2:nobs,1);
xt = x(2:nobs,:);
 
// use cochrane-orcutt estimates as initial values
///[rho,bet]=olsc0(y,x,2000,sqrt(%eps));


// use LS estimates as initial values 
bet = ols0(y,x)
res = y-x*bet 
lres = trimr(lag(res,1),1,0)
res = trimr(res,1,0)
rho = ols0(res,lres)

parm = [rho ; bet]
deff('[f,g,ind]=cost(parm,ind)',..
     ['f=ar1_like(parm,y,x)';...
     'g=ar1_grad(parm,y,x)'])

binf=[-1+%eps ; -%inf*ones(nvar,1)]
[like,bet] = optim(cost,'b',binf,-binf,parm);
llike = -like-nobs/2*(1+ log(2*%pi)-log(nobs))
 
// after convergence produce a final set of estimates using rho-value
rho = bet(1,1);
ys = y-rho*lag(y);
xs = x-rho*lag(x);
ys(1,1) = sqrt(1-rho*rho)*y(1,1);
xs(1,:) = sqrt(1-rho*rho)*x(1,:);
// provides the results from the regression of the vector y
// on the vector x
rolsar=ols2(ys,xs)

result('meth')='ar(1) maximum likelihood'
// compute t-statistic for rho
varrho = (1-rho*rho)/(nobs-2);
rolsar(1)($+1)='rho'
rolsar('rho')=rho
rolsar(1)($+1)='trho'
rolsar('trho')=rho/sqrt(varrho)
rolsar(1)($+1)='like'
rolsar('like')=llike

endfunction
