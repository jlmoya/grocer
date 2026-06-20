function [res]=kpss(grocer_namey,grocer_p,grocer_l,varargin)
 
// PURPOSE: performs the KPSS test
// ------------------------------------------------------------
// REFERENCES:  Kwiatkowski, D., P. Phillips, P. Schmidt, and
// Y. Shin (1992), "Testing the Null of Stationarity Against
// the Alternative of a Unit Root", Journal of Econometrics 54,
// pp. 159-178.
// ------------------------------------------------------------
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * grocer_p=order of time polynomial in the null-hypothesis
//      grocer_p =  0, for constant term
//      grocer_p =  1, for constant plus time-trend
// * grocer_l (optional) = truncation lag of the Newey-West
//   windows
//   default : l= floor(5*nobs^0.25)
// * varargin = optional arguments which can be:
//  - 'noprint' if the user doesn't want to print the results of
//     the regression
//  - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUPTUT:
// res = results tlist with:
//  . res('meth') = 'kpss'
//  . res('namey') = namey
//  . res('y') = y
//  . res('t') = t
//  . res('lag(N_W)') = l
//  . res('test_value') = lm
//  . res('prests') = prests
//  . res('1% level') = 1% critical value
//  . res('51% level') = 5% critical value
//  . res('10% level') = 10% critical value
//  . res('bounds') = bounds fo the regression (if any)
//  . res('dropna') = boolean indicating if NAs have
//    been droped
//  . res('nonna') = vector indicating position of
//    non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 20002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
tab=[0.739 0.463 0.347 ;
     0.216 0.146 0.119]
 
[nargout,nargin] = argn(0)
if nargin > 2 then
   [grocer_dropna,grocer_prt]=vararg2dropnaprt(varargin(:))
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
   nobs=size(y,1)
   if isempty(grocer_l) then
        grocer_l=floor(5*nobs^0.25)
   end
elseif nargin ==  2 then
   grocer_dropna=%f
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
   nobs=size(y,1)
   grocer_prt=%t
   grocer_l=floor(5*nobs^0.25)
else
   error('invalid number of arguments')
end
 
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('bounds are discontinous in kpss')
   end
end
 
r=ols1(y,ptrend(grocer_p,nobs))
e=r('resid')(1)
for i=2:nobs
   e=[e ; e(i-1)+r('resid')(i)]
end
sigma2=newey_west(r('resid'),grocer_l)
lm=sum(e.^2)/sigma2/nobs^2
 
 
res=tlist(['results';'meth';'namey';'y';'p';'lag(N_W)';...
'test_value';'prests';'1% level';'5% level';'10% level';'dropna'],...
'kpss',namey,y,grocer_p,grocer_l,lm,prests,tab(grocer_p+1,1),..
tab(grocer_p+1,2),tab(grocer_p+1,3),grocer_dropna)
 
if grocer_dropna then
   resers(1)($+1)='nonna'
   resers('nonna')=nonna
end
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds') = boundsvarb
end
 
if grocer_prt then
   prtunitr(res)
end
 
endfunction
