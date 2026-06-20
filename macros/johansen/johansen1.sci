function [result]=johansen1(y,exo_lt,exo_st,grocer_k,stat_meth,grocer_max_nonzeros)
 
// PURPOSE: perform Johansen cointegration tests
// ------------------------------------------------------------
// * References:
// - Johansen (1988), 'Statistical Analysis of
// Co-integration vectors', Journal of Economic Dynamics and
// Control, 12, pp. 231-254.
// - Jueslius (2006): The Cointegrated VAR Model: Methodlogy
// and Applications, Oxford University Press.
// ------------------------------------------------------------
// INPUT:
// * k = number of lagged difference terms used when
//                 computing the estimator
// * varargin = arguments which can be:
//   . a time series
//   . a real (n x 1) vector
//   . a string equal to the names of a time series or a (nx1)
//     real vector between quotes
//   . the string 'exo_st=exo_st1,exo_st2,...exo_stn' where
//     exo_sti is the names of an exogenous variable to be added
//     to the short run dynamic of the VAR
//   . the string 'exo_lt=exo_lt1,exo_lt2,...exo_ltn' where
//     exo_lti is the names of an exogenous variable to be added
//     to the cointegrating vectors
//   . the string 'NBoot=n' where n is the number of bootstrap
//     draws (default: 999)
//   . the string 'max_nonzeros=n' where n is the maximum
//     number of zeros a variable must have to be considered
//     as a dummy (default: 4)
//   . the string 'stat_meth=asym' if the user wants to use 
//     asymptotic critical tables instead of the bootstrapped
//     default ones
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//  - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// result = a results tlist with:
//   - result('meth') = 'johansen'
//   - result('namey') = the names of the variables (m x 1)
//   - result('y') = matrix of values for the variables
//                    (m x 1)
//   - result('namexo_lt') = the names of the exogenous variables
//     in the cointegrating vectors
//   - result('exo_lt') = the matrix of the exogenous variables
//     in the cointegrating vectors
//   - result('namexo_st') = the names of the exogenous variables
//     in the short run dynamic of the VAR
//   - result('exo_st') = the matrix of the exogenous variables
//     in the short run dynamic of the VAR
//   - result('dy') = the matrix of the differentiated endogenous
//     variables
//   - result('exo') = the matrix of the variables in the short
//     run dynamics (lagged diffrentiated endogenous variables +
//     short run exogenous variables)
//   - result('lagy') = the matrix of the variables in the
//     cointegrating relations (lagged endogenous variables +
//     long run exogenous variables)
//   - result('nobs') = # of observations
//   - result('nvar') = # of variables
//   - result('nlags') = # of lags of the VAR
//   - result('eig') = eigenvalues (m x 1)
//   - result('evec') = eigenvectors (m x m)
//   - result('pi') = coefficients of the short run dynamic
//   - result('lr1') = likelihood ratio trace statistics for
//                       r=0 to m-1, a (m x 1) vector
//   - result('lr2') = maximum eigenvalue statistic for r=0
//                       to m-1, a (m x 1) vector
//   - result('dropna') = boolean indicating if NAs have
//     been dropped
//   - result('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
//   - result('max non zeros') = maximum number of zeros a
//     variable had to be considered as a dummy
//   - result('NBoot') = # of bootstrap draws
//   - result('alpha') = value of the error correction
//     coefficients
//   - result('cvt') = critical values for trace statistic
//                        (m x 3) vector [90% 95% 99%]
//   - result('cvm') = critical values for max eigen value
//                       statistic (3 x m) vector [90% 95% 99%]
//   - result('p trace') = p-value for the trace statistic
//     calculated with the standard bootstrap method
//   - result('p lmax') = p-value for the lambda-max statistic
//     calculated with the standard bootstrap method
//   - result('p double trace') = p-value for the trace statistic
//     calculated with the double bootstrap method
//   - result('p double lmax') = p-value for the lambda-max
//     statistic calculated with the double bootstrap method
//   - result('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   - result('bounds') = if there is a time series in the
//     regression, the bounds of the regression
// ------------------------------------------------------------
// NOTE: uses the function johansen_eigen adapted from a
// programm by James LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the trace and max eignevalues statistics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://dubois.ensae.net/grocer.html
 
 

nobs=size(y,1) 
dy = [0*y(1,:) ; y(2:nobs,:)-y(1:nobs-1,:)]
exo=[trimr(mlagb(dy,grocer_k),grocer_k+1,0) exo_st]
lagy = [y(grocer_k+1:nobs-1,:) exo_lt]
dy=dy(grocer_k+2:$,:)
[nobs,ny]=size(dy)
nlagy=size(lagy,2)
 
[flag,lambda,evec,lr1,lr2,pi,s00,lambda2]=johansen_eigen(dy,exo,lagy)
if flag == 'not OK' then
    if lambda2 < 1E8 then
       write(%io(2),'error: ')
       write(%io(2),'you should inter alii check if you have not entered the same variable')
       write(%io(2),'as short and long run exogenous variables')
    end
end
omega=sum(log(1-lambda))
aic=omega+2*((grocer_k+1+size(exo_lt,2))*ny+size(exo_st,2))/nobs
bic=omega+((grocer_k+1+size(exo_lt,2))*ny+size(exo_st,2))*log(nobs)/nobs
hq=omega+2*((grocer_k+1+size(exo_lt,2))*ny+size(exo_st,2))/log(log(nobs))

// set up first results tlist
result = tlist(['results';'meth';'stat_meth';'namey';'y';'namexo_lt';'exo_lt';...
'namexo_st';'exo_st';'dy';'exo';'lagy';'nobs';'nvar';...
'nlags';'eig';'evec';'pi';'lr1';'lr2';'dropna';'max non zeros';'aic';'bic';'hq'],...
'johansen',stat_meth,[],y,[],exo_lt,[],exo_st,dy,exo,lagy,...
nobs,ny,grocer_k,lambda,evec,pi,lr1,lr2,[],4,aic,bic,hq)

b=ols0(dy,[lagy*evec exo])
alpha=b(1:ny,:)
gam=b(ny+1:$,:)
 
result(1)($+1)='alpha'
result('alpha')=alpha

if stat_meth == 'bootstrap' then
   result=johansen_bootstrap(result,grocer_NBoot,dy,lagy,exo,exo_lt,evec,alpha,gam,nobs,grocer_max_nonzeros) 
else 
   [result]=johansen_asym(result,ny,exo_st)
end

 
endfunction
