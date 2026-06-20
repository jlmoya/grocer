function [result]=olsar1_1(y,x,optfunc,opt_optim)
 
// PURPOSE: computes maximum likelihood ols regression for AR1
// errors
// ------------------------------------------------------------
// INPUT:
// * y = a real (n,1) vector or a
// * x = a real (n,k) matrix
// * optfunc =  the name of the optimisation function
//   (optim or optimg)
// * opt_optim = a tlist, collecting the options to
//   the optimisation function
//---------------------------------------------------
// rolsar1 = a results tlist with
//   . rolsar1('meth')  = 'ar(1) maximum likelihood'
//   . rolsar1('y')     = y data vector
//   . rolsar1('x')     = x data matrix
//   . rolsar1('nobs')  = # observations
//   . rolsar1('nvar')  = # variables
//   . rolsar1('beta')  = bhat
//   . rolsar1('yhat')  = yhat
//   . rolsar1('resid') = residuals
//   . rolsar1('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolsar1('sige')  = estimated variance of the residuals
//   . rolsar1('sigu')  = sum of squared residuals
//   . rolsar1('ser')  = standard error of the regression
//   . rolsar1('tstat') = t-stats
//   . rolsar1('pvalue') = pvalue of the betas
//   . rolsar1('dw')    = Durbin-Watson Statistic
//   . rolsar1('condindex') = multicolinearity cond index
//   . rolsar1('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rolsar1('rsqr')  = rsquared
//   . rolsar1('rbar')  = rbar-squared
//   . rolsar1('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rolsar1('pvaluef') = its significance level
//   . rolsar1('rho') = estimated first order autocorrelation of residuals
//   . rolsar1('trho') = its Student t
//   . rolsar1('like') = log-likelihood of the regression
// --------------------------------------------------
 
 
[nobs,nvar] = size(x);
[nobs2] = size(y,1);
  
// use cochrane-orcutt estimates as initial values
 
[rho,bet]=olsc0(y,x,10,sqrt(%eps),%f);
parm = [rho ; bet]
 
deff('[f,g,ind]=cost(parm,ind)',..
     ['f=ar1_like(parm,y,x)';...
     'g=ar1_grad(parm,y,x)'])

select optfunc
case 'optim' then
   execstr('[like,bet,grad] = optim(cost'...
   +opt_optim('optim ineq')+',parm'+opt_optim('optim')+')')

case 'optimg' then
    warning('constraints are not taken into account with optimg')
   [like,bet,grad] = optimg(ar1_like,cost,parm,...
       opt_optim('optim'),opt_optim('nelmead'),opt_optim('convg'));
else
   error('not an available optimisation function'+optfunc)
end
llike = -like+nobs/2*(log(nobs)-log(2*%pi))
 
// after convergence produce a final set of estimates using rho-value
rho = bet(1,1);
ys = y-rho*[0 ; y(1:$-1)];
xs = x-rho*[0*x(1,:) ; x(1:$-1,:)];
ys(1,1) = sqrt(1-rho*rho)*y(1,1);
xs(1,:) = sqrt(1-rho*rho)*x(1,:);
 
// provides the results from the regression of the vector y
// on the vector x
result=ols2(ys,xs)
 
result('meth')='ar(1) maximum likelihood'
// compute t-statistic for rho
u=y-x*bet(2:$)
u_l1=u(1:nobs-1)
varrho = result('sige')/(u_l1'*u_l1)
result(1)($+1)='rho'
result('rho')=rho
result(1)($+1)='trho'
result('trho')=rho/sqrt(varrho)
result(1)($+1)='like'
result('like')=llike
result(1)($+1)='grad'
result('grad')=-grad

endfunction
