function [result]=johansen(grocer_k,varargin)
 
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
//   . a string equal to the names of a time series or a (n x 1)
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
// http://grocer.toolbox.free.fr/grocer.html
 
 
// set defaults
grocer_max_nonzeros=4
grocer_dropna=%f
grocer_prt=%t
grocer_exo_lt=[]
grocer_exo_st=[]
grocer_stat_meth='bootstrap'
grocer_NBoot=999
 
// separates from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argin=strsubst(grocer_argi,' ','')
      grocer_str7=part(strsubst(grocer_argin,' ',''),1:7)
 
      if or(grocer_str7 == ['exo_lt=';'exo_st=']) then
         execstr('grocer_'+grocer_str7+'string2vec(part(grocer_argi,8:length(grocer_argi)),'';'')')
         varargin(grocer_i) =null()
      elseif part(grocer_argin,1:6) == 'NBoot=' then
         execstr('grocer_'+grocer_argin)
         varargin(grocer_i) =null()
      elseif part(grocer_argin,1:13) == 'max_nonzeros=' then
         execstr('grocer_'+grocer_argin)
         varargin(grocer_i) =null()
      elseif part(grocer_argin,1:10) == 'stat_meth=' then
         execstr('grocer_stat_meth='''+part(grocer_argin,11:length(grocer_argin))+'''')
         varargin(grocer_i) =null()
      elseif grocer_argin == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i) =null()
      elseif grocer_argin == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i) =null()
      end
   end
end
 
[mats,names,prests,boun,nonna]=explon(list(varargin,grocer_exo_lt,grocer_exo_st),...
['endogenous' 'l.t. exogenous' 's.t. exogenous'],[],%t,grocer_dropna,%f,[grocer_k+1;0;0])
 
y=mats(1)
exo_lt=mats(2)
exo_st=mats(3)
 
[result]=johansen1(y,exo_lt,exo_st,grocer_k,grocer_stat_meth,grocer_max_nonzeros)

// enter the names of the variables
result('namey')=names(1)
result('namexo_lt')=names(2)
result('namexo_st')=names(3)
result('dropna')=grocer_dropna

result(1)($+1) = 'prests'
result('prests')=prests
if prests then
   result(1)($+1) = 'bounds'
   result('bounds')=boun
end
 
if grocer_dropna then
   result(1)($+1)='nonna'
   result('nonna')=nonna
end
 
if grocer_prt then
   prtjohan(result)
end
 
endfunction
