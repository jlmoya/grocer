function [grocer_model,rivmod]=ivmod(grocer_model,grocer_tsmat,grocer_indeq,grocer_endo,grocer_ivar,varargin)
 
// PURPOSE: estimate with instrumental variables an equation
// of a model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate
//   - or an integer, the # of the equation in the model
// * grocer_endo =
//  - a string vector, the names of the variables that will be
//   instrumented
//  - or a list of variables, each entered between quotes
// * grocer_ivar =
//   - a string vector, the names of the instruments
//   - a list, each element in the list conating the list of
//     instruments for the variable at the same rank in the list
//     of endogenous variables given in the previous input
// * varargin = optional arguments
//   - 'noprint' if the user does not want to print the result
//   (default: results are displayed on screen)
//   - 'save=%t' if the user wants to save the estimated
//   coefficients in the model tlist
// ------------------------------------------------------------
// OUTPUT:
// * grocer_model = the model tlist, with the estimated
//   coefficients if the option save has been swtiched to %t
// * rivmod = a results tlist, with:
//   . rivmod('meth')  = 'iv'
//   . rivmod('y')     = y data vector
//   . rivmod('x')     = x data matrix
//   . rivmod('nobs')  = # observations
//   . rivmod('nvar')  = # variables
//   . rivmod('beta')  = bhat
//   . rivmod('yhat')  = yhat
//   . rivmod('resid') = residuals
//   . rivmod('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rivmod('sige')  = estimated variance of the residuals
//   . rivmod('sigu')  = sum of squared residuals
//   . rivmod('ser')  = standard error of the regression
//   . rivmod('tstat') = t-stats
//   . rivmod('pvalue') = pvalue of the betas
//   . rivmod('dw')    = Durbin-Watson Statistic
//   . rivmod('condindex') = multicolinearity cond index
//   . rivmod('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rivmod('llike') = the log-likelihood
//   . rivmod('aic')= the Akaike information criterion
//   . rivmod('bic')= the Schwarz information criterion
//   . rivmod('hq')= the Hannan-Quinn information criterion
//   . rivmod('rsqr')  = rsquared
//   . rivmod('rbar')  = rbar-squared
//   . rivmod('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rivmod('pvaluef') = its significance level
//   . rivmod('grsqr')  = generalized R-squared (the one where
//     the instrumented variable is replaced with its regression
//     on the instrument
//   . rivmod('grbar')  = rbar-squared
//   . rivmod('fg')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rivmod('pvaluefg') = its significance level
//   . rivmod('like') = log-likelihood of the regression
//   . rivmod('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rivmod('namey') = name of the y variable
//   . rivmod('namex') = name of the coefficients
//   . rivmod('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rivmod('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rivmod('nonna') = vector indicating position of non-NAs
//   . rivmod('saturation significance level') = significance
//     level used to keep the dummies
//   . rivmod('significant dummies') = the remaining dummies
//     after testing
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2023
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_dropna=%f
grocer_prt=%t
grocer_save=%f
 
varargout=list()
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=stripblanks(varargin(grocer_i))
   if typeof(grocer_argi) == 'string' then
      if part(grocer_argi,1:4) == 'save'
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      end
   end
end
 
if typeof(grocer_model) == 'string' then
   grocer_model=create_model(grocer_model)
end
 
grocer_equations=grocer_model('equations')
grocer_linear=grocer_model('linearity')
grocer_coeffs=grocer_model('coeffs')
grocer_params=grocer_model('params')
grocer_namecoefs=grocer_coeffs(1)(2:$)
grocer_nameparams=grocer_params(1)(2:$)
grocer_namendos=grocer_model('name endo')
grocer_namexos=grocer_model('name exo')
grocer_nameresids=grocer_model('name resid')
grocer_listexog=grocer_model('names for regressions')
 
grocer_resid=grocer_model('name resid')
 
grocer_tsmat_names=grocer_tsmat('names')
grocer_series=grocer_tsmat('series')
[grocer_nobs,grocer_nseries]=size(grocer_series)
grocer_one=tlist(['ts';'freq';'dates';'series'],grocer_tsmat('freq'),grocer_tsmat('dates'),ones(size(grocer_series,1),1))
grocer_ts=grocer_one
grocer_zero=grocer_ts
grocer_zero('series')=zeros(size(grocer_series,1),1)
for grocer_i=1:grocer_nseries
   grocer_ts('series')=grocer_series(:,grocer_i)
   execstr(grocer_tsmat_names(grocer_i)+'=grocer_ts')
end
 
if typeof(grocer_indeq) == 'string' then
   grocer_nameq=grocer_model('name eq')
   grocer_indeqj=find(grocer_nameq == grocer_indeq)
 
elseif typeof(grocer_indeq) == 'constant' then
   grocer_indeqj=grocer_indeq
 
end
 
grocer_eqj=grocer_equations(grocer_indeqj)
grocer_indeqj_listexog=grocer_listexog(grocer_indeqj)
grocer_indeqj_namecoef=grocer_indeqj_listexog(:,1)
if isempty(grocer_indeqj_namecoef) then
   error('equation '+string(grocer_indeq)+' has no coefficient')
end
grocer_indeqj_namexos=grocer_indeqj_listexog(:,2)
grocer_eqj_namevari=[grocer_namendos(find(grocer_model('eq endos')(:,grocer_indeqj)~=0)) ;
                    grocer_namexos(find(grocer_model('eq exos')(:,grocer_indeqj)~=0)) ]
 
 
for grocer_i=1:size(grocer_eqj_namevari,1)
   grocer_k=find(grocer_tsmat_names == grocer_eqj_namevari(grocer_i))
   if isempty(grocer_k) then
      warning('series '+grocer_eqj_namevari(grocer_i)+' not in input tsmat; program will use an existing variable with that name, if any')
   else
      grocer_ts('series')=grocer_series(:,grocer_k)
      execstr(grocer_eqj_namevari(grocer_i)+'=grocer_ts')
   end
end
 
grocer_eqj_resid=grocer_nameresids(find(grocer_model('eq resids')(:,grocer_indeqj)~=0))
for grocer_i=1:size(grocer_eqj_resid,1)
   execstr(grocer_eqj_resid(grocer_i)+'=grocer_zero')
end
 
execstr(grocer_indeqj_namecoef+'=0')
grocer_indequal=strindex(grocer_eqj,'=')
grocer_namey=strsubst(part(grocer_eqj,1:grocer_indequal-1)+'-('+part(grocer_eqj,grocer_indequal+1:length(grocer_eqj))'+')',' ','')
 
select typeof(grocer_endo)
 
case 'string' then
   grocer_nendo=size(grocer_endo,'*')
 
case 'list' then
   grocer_nendo=length(grocer_endo)
 
end
 
grocer_varendo=list()
for grocer_i=1:size(grocer_indeqj_namexos,'*')
   grocer_varendo(grocer_i)=evstr(grocer_indeqj_namexos(grocer_i))
end
 
for grocer_i=1:grocer_nendo
   grocer_endoi=evstr(grocer_endo(grocer_i))
   grocer_nobsi=size(grocer_endoi('series'),1)
   grocer_indnonna=find(~isnan(grocer_endoi('series')))
   grocer_j=0
   grocer_found=%f
   while ~grocer_found & (grocer_j < size(grocer_indeqj_namexos,1))
      grocer_j=grocer_j+1
      grocer_diff=grocer_endoi-grocer_varendo(grocer_j)
      if grocer_nobsi == size(grocer_diff('series'),1) then
         grocer_diff_s=grocer_diff('series')
         if and(grocer_diff_s(grocer_indnonna) == 0) then
            grocer_found=%t
         end
      end
   end
   if ~grocer_found then
      error(grocer_endo(grocer_i)+' not found on the list of exogenous variables in equation '+grocer_indeq)
   end
 
   grocer_indeqj_namexos(grocer_j)=[]
   grocer_namex=[grocer_indeqj_namecoef(grocer_j) ; grocer_indeqj_namecoef(1:grocer_j-1) ; grocer_indeqj_namecoef(grocer_j+1:$)]
end
[mats,names,prests,boun]=explon(list(grocer_namey,grocer_endo,strsubst(grocer_indeqj_namexos,' ',''),grocer_ivar),...
                     ['endogenous' 'rhs endogenous' 'exogenous' 'instruments'],[],%t,grocer_dropna)
// provides the results from the regression of the vector y
// on the vector x
y=mats(1)
y1=mats(2)
x1=mats(3)
xall=mats(4)
 
rivmod=iv1(y,y1,x1,xall)
 
// saves the names, the bounds if the regression involves ts
rivmod(1)($+1) = 'prests'
rivmod(1)($+1) = 'namex'
rivmod(1)($+1) = 'nameendo'
rivmod(1)($+1) = 'namey'
rivmod(1)($+1) = 'nameinst'
rivmod(1)($+1) = 'dropna'
rivmod('prests')=%t
rivmod('namex')=grocer_namex
rivmod('nameendo')=names(2)
rivmod('namey')=grocer_equations(grocer_indeqj)
rivmod('nameinst')=names(4)
rivmod('dropna')=%f
 
rivmod(1)($+1) = 'bounds'
rivmod('bounds')=boun
 
if grocer_prt then
   prtuniv(rivmod)
end
 
if grocer_save then
   grocer_bet=rivmod('beta')
   for grocer_k=1:size(grocer_namex,1)
       grocer_indcoeff_k=find(grocer_namecoefs == grocer_namex(grocer_k))
       grocer_coeffs(grocer_indcoeff_k+1)=grocer_bet(grocer_k)
   end
   grocer_model('coeffs')=grocer_coeffs
end
 
endfunction
