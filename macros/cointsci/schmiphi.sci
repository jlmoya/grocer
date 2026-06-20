function [resulsp]=schmiphi(grocer_namey,grocer_p,varargin)
 
// PURPOSE: computes Schmidt-Phillips test
// ------------------------------------------------------------
// INPUT:
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
// resulsp = results tlist with:
// - resulsp('meth') = 'schmiphi'
// - resulsp('namey') = name of the tested variable
// - resulsp('y') = (nobsx1) vector of endogenous variables
// - resulsp('nobs') = # of observations
// - resulsp('t') = order of the polynomial trend
// - resulsp('lag(NW)') = # of lags of the Newey-West window
// - resulsp('phi') = value of the phi test
// - resulsp('rho') = rho statistics
// - resulsp('tstat') = tstat statisctics
// - resulsp('v_rho_1%') = critical value of the rho-test at
//                        the 1% level
// - resulsp('v_rho_5%') = critical value of the rho-test at
//                        the 5% level
// - resulsp('v_rho_10%') = critical value of the rho-test at
//                        the 10% level
// - resulsp('v_tstat_1%') = critical value of the tstat-test at
//                        the 1% level
// - resulsp('v_tstat_5%') = critical value of the tstat-test at
//                        the 5% level
// - resulsp('v_tstat_10%') = critical value of the tstat-test at the
//                       10% level
// - resulsp('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - resulsp('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// - resulsp('dropna') = boolean indicating if NAs have
//    been droped
// - resulsp('nonna') = vector indicating position of
//    non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// REFERENCE:
// Schmidt, P. and Phillips P.C. (1992) : "LM TEST FOR A UNIT
// ROOT IN THE PRESENCE OF DETERMINISTIC TRENDS", Oxford
// Bulletin of economics and Statistics, pp. 257-287.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_dropna=%f
grocer_prt=%t
 
[nargout,nargin] = argn(0)
if nargin < 2 then
   error('nargin should be at least 2')
end
 
for grocer_i=3:nargin
   argi=varargin(grocer_i-2)
 
   select typeof(argi)
 
   case 'string' then
      select strsubst(argi,' ' ,'')
      case 'noprint' then
         grocer_prt=%f
      case 'dropna' then
         grocer_dropna=%t
      else
         error('not an available option: '+argi)
      end
 
   case 'constant' then
      grocer_l=argi
 
   else
      error(typeof(argi)+' is not an suitable type')
   end
 
end
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
 
nobs=size(y,1)
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) ~= 2 then
      error('bounds are discontinous in schmiphi')
   end
end
 
if ~exists('grocer_l','local') then
   grocer_l=floor(5*nobs^0.25)
end
 
ksi= (y(nobs)-y(1))/(nobs-1)
psi=y(1)-ksi
sbar=y(1:nobs-1)-psi-ksi*[0:nobs-2]'
dy=y(2:nobs)-y(1:nobs-1)
 
r=ols1(dy,[sbar ptrend(grocer_p,nobs-1)])
phi=r('beta')(1)
resid=r('resid')
 
// apply the newey-west correction to the statistics
correc=r('sigu')/nobs/newey_west(r('resid'),grocer_l)
rho=nobs*phi/correc
tstat=r('tstat')(1)/sqrt(correc)
 
[critical1,critical2]=schmiphi_tab(grocer_p,nobs)
 
resulsp=tlist(['results';'meth';'namey';'y';'nobs';'p';'lag(NW)';...
'phi';'rho';'tstat';'cv_rho_1%';'cv_rho_5%';'cv_rho_10%';...
'cv_tstat_1%';'cv_tstat_5%';'cv_tstat_10%';'prests';'dropna'],'Schmidt-Phillips',...
namey,y,nobs,grocer_p,grocer_l,phi,rho,tstat,...
critical1(1),critical1(3),critical1(4),critical2(1),...
critical2(3),critical2(4),prests,grocer_dropna)
 
if grocer_dropna then
   resulsp(1)($+1)='nonna'
   resulsp('nonna')=nonna
end
 
if prests then
   resulsp(1)($+1) = 'bounds'
   resulsp('bounds') = boundsvarb
end
 
if grocer_prt then
   prt_phil_perr(resulsp,%io(2))
end
 
endfunction
