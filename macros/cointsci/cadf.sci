function [rescadf]=cadf(grocer_p,grocer_l,grocer_namey,varargin)
 
// PURPOSE: compute augmented Dickey-Fuller statistic for
// residuals from a cointegrating regression, allowing for
// deterministic polynomial trends
// ------------------------------------------------------------
// References: Said and Dickey (1984) 'Testing for Unit Roots
// in Autoregressive Moving Average Models of Unknown Order',
// Biometrika, Volume 71, pp. 599-607.
// ------------------------------------------------------------
// INPUT:
// * p = order of time polynomial in the null-hypothesis
//   . p = -1, no deterministic part
//   . p =  0, for constant term
//   . p =  1, for constant plus time-trend
//   . p >  1, for higher order polynomial
// * l = # of lagged changes of the residuals to include in
//   regression
// * namey = a time series, a real (nx1) vector or a string
// equal to the name of a time series or a (nx1) real vector
// between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nx1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'dropna' if the user wants to remove the NA
//     values from the data
// ------------------------------------------------------------
// OUTPUT:
// rcadf = a tlist with
//   . all of the arguments of the second stage regression
//   and
//   . rcadf('cointrel') = tlist with all the arguments of the
//   first stage regression
// (see ols() for a description of all these arguments)
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// Modeled after a similar Gauss routine by
// Sam Ouliaris, in a package called COINT
 
// set defaults
grocer_dropna=%f
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
// error checking
if grocer_p<(-1) then
  error('p cannot be < -1 in cadf');
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
explouniv(grocer_namey,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
if grocer_p >= 0 then
   n=size(grocer_y,1)
   grocer_x=[grocer_x ptrend(grocer_p,n)]
   grocer_namexos=[grocer_namexos ; 'cte']
   if grocer_p > 0 then
      grocer_namexos=[grocer_namexos ; 't' ]
   end
   if grocer_p > 1 then
      grocer_namexos=[grocer_namexos ; 't^'+string([2:grocer_p])]
   end
end
 
// provides the results from the regression of the vector y
// on the vector x
rols=ols2(grocer_y,grocer_x)
 
// saves the names, the bounds if the regression involves ts
rols(1)($+1) = 'prests'
rols(1)($+1) = 'namex'
rols(1)($+1) = 'namey'
rols('prests')=grocer_prests
rols('namex')=grocer_namexos
rols('namey')=grocer_namey
rols(1)($+1) = 'dropna'
rols('dropna')=grocer_dropna
 
resid=rols('resid')
nobs=rols('nobs')
dep = resid(2:nobs)-resid(1:nobs-1);
z=[resid(grocer_l+1:nobs-1) zeros(nobs-grocer_l-1,grocer_l)]
for k=1:grocer_l
   z(:,k+1) = dep(grocer_l-k+1:nobs-1-k)
end
dep = dep(grocer_l+1:$,:);
 
rescadf=ols2(dep,z)
 
grocer_namexos=['res(-1)']
for i=1:grocer_l
   grocer_namexos=[grocer_namexos ; 'del(res(-'+string(i)+"))"]
end
 
rescadf('meth')='cadf'
rescadf(1)($+1) = 'prests'
rescadf(1)($+1) = 'namex'
rescadf(1)($+1) = 'namey'
rescadf('prests')=grocer_prests
rescadf('namex')=grocer_namexos
rescadf('namey')='del(res)'
rescadf(1)($+1) = 'cointrel'
rescadf(1)($+1) = 'trend'
rescadf('trend') = grocer_p
 
rescadf(1)($+1) = 'dropna'
rescadf('dropna')=grocer_dropna
if grocer_dropna then
   rols(1)($+1)='nonna'
   rols('nonna')=nonna
   rescadf(1)($+1)='nonna'
   rescadf('nonna')=nonna(1+grocer_l:$)
end
 
if grocer_prests then
   rols(1)($+1) = 'bounds'
   rols('bounds')=grocer_boundsvarb
   rescadf(1)($+1)='bounds'
   [b1,fq]=date2num_fq(grocer_boundsvarb(1))
   rescadf('bounds')=[num2date(b1+grocer_l+1,fq) ; grocer_boundsvarb(2)]
end
rescadf('cointrel') = rols
 
crit=rztcrit(rescadf('nobs'),size(rols('x'),2)-grocer_p-1,grocer_p)
 
rescadf(1)($+1) = '1% level'
rescadf('1% level') = crit(1)
rescadf(1)($+1) = '5% level'
rescadf('5% level') = crit(2)
rescadf(1)($+1) = '10% level'
rescadf('10% level') = crit(3)
 
if grocer_prt then
   prt_cadf(rescadf)
end
 
endfunction
