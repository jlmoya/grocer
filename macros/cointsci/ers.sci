function [res]=ers(grocer_namey,grocer_p,grocer_l,varargin)
 
// PURPOSE: carry out Elliott-Rothenberg-Stock (ERS) test on a
// time-series vector
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (n x 1) vector or a
// string equal to the name of a time series or a (n x 1) real
// vector between quotes
// * grocer_p = order of time polynomial in the null-hypothesis
//   . grocer_p =  0, for constant term
//   . grocer_p =  1, for constant plus time-trend
// * grocer_l = # of lags of the ERS test
// * varargin = optional arguments which can be:
//  - 'noprint' if the user doesn't want to print the results of
//     the regression
//  - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with
//   . res('meth')  = 'ers'
//   . res('y')     = y data vector of the auxiliary
//     regression
//   . res('x')     = x data matrix of the auxiliary
//     regression
//   . res('nobs')  = # observations
//   . res('nvar')  = # variables
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals of the auxiliary regression
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sigu')  = sum of squared residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('dw')    = Durbin-Watson Statistic
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the absence of a
//     constant in the regression
//   . res('test p-value') = the (approximate) p-value of
//     the test
//   . res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . res('namey') = name of the y variable of the auxiliary
//     regression
//   . res('namex') = name of the x variables of the auxiliary
//     regression
//   . res('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . res('like') = log-likelihood of the regression
//   . res('dropna') = boolean indicating if NAs have
//     been droped
//   . res('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2015
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_dropna,grocer_prt]=vararg2dropnaprt(varargin(:))
 
// error checking
if and(grocer_p ~= [0 1]) then
  error('p can only be 0 or 1 in ers');
end
 
// explodes the list of the arguments into the corresponding
// variables, their names, and, if necessary updates the bounds
[y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna,%f,grocer_l)
 
n=size(y,1)
l_n=(grocer_l/n)
 
select grocer_p
case 0 then
   zt=ones(n,1)
   zt_tilde=zt-(1-7/n)*[0 ; ones(n-1,1)]
   yt_tilde_k=y-(1-7/n)*[0 ; y(1:$-1,:)]
   load(GROCERDIR+'\data\ers_tabmu.dat')
   ers_distrib=ers_tabmu*[1 n^(-0.25) n^(-0.5) 1/n (1/n)^2 l_n^0.25 l_n^0.5 l_n l_n^2]'
 
case 1 then
   zt=[ones(1,n) ; 1:n]'
   zt_tilde=zt-(1-13.5/n)*[0 0 ; zt(1:$-1,:)]
   yt_tilde_k=y-(1-13.5/n)*[0 ; y(1:$-1,:)]
   load(GROCERDIR+'\data\ers_tabtau.dat')
   ers_distrib=ers_tabtau*[1 n^(-0.25) n^(-0.5) 1/n l_n^0.25 l_n^0.5 l_n l_n^2]'
 
else
   error(string(grocer_p)+' is not allowed in ers')
end
 
y_tau_k=y-zt*ols0(yt_tilde_k,zt_tilde)
y_tau_lag=[0 ; y_tau_k(1:$-1)]
dy_tau=y_tau_k-y_tau_lag
dy_tau_lags=mlag(dy_tau,grocer_l)
 
// remove the first observations
 
y_tau_lag=y_tau_lag(grocer_l+2:n)
dy_tau=dy_tau(grocer_l+2:n)
dy_tau_lags=dy_tau_lags(grocer_l+2:n,:)
 
res=ols2(dy_tau,[y_tau_lag dy_tau_lags])
res('meth')='ers'
res(1)($+1)='test p-value'
res(1)($+1)='trend'
t=res('tstat')(1)
indp=find(ers_distrib<t)
ers_p_value=indp($)/10000
res('test p-value')=ers_p_value
res('trend')=grocer_p
 
// saves the names, the bounds if the regression involves ts
res(1)($+1) = 'prests'
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
res('prests')=prests
res('namey')=namey
res('namex')=[namey+'[-1]' ; 'del('+namey+'[-'+string([1:grocer_l]')+'])']
res(1)($+1) = 'dropna'
res('dropna')=grocer_dropna
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=[num2date(date2num(boundsvarb(1))+grocer_l,...
              date2fq(boundsvarb(1))) ; boundsvarb(2)]
end
 
if grocer_prt then
   prt_ers(res,%io(2))
end
 
endfunction
