function [yhf,retal] = etalcalinsee(grocer_namey,varargin)
 
// PURPOSE: provide Insee's method for desaggegating time
// series with a high frequency indicator. The regression
// allows for:
//    (a) AR(1) or RW résiduals
//    (b) inclusion or exclusion of a constant
// ------------------------------------------------------------
// INPUT:
// * grocer_namey  = low frequency series
// * varargin = strings that can be
//  .'s=xx' frequency of the desired output and, accordingly,
//    of the indicators (default: 4)
//  .'alpha =xx' where w is significance level for the constant
//    default 0.1, that is 10%)
//  .'ny_prov =n' where n is the number of known low frequency data
//    that are ignored in the diseggregation process
//  .'mod=''rw''' if the residuals are supposed to be a RW or
//   'mod=''ar''' if the residuals are supposed to be an AR(1)
//  (default: model with maximum likelihood is chosen)
//  .'bench=''xxx''' where xxx is the name of the series the
//    user wants to compare the result with (for instance to
//    compare the method with another one)
//  .'noprint' if the user does not want to print the results
// ------------------------------------------------------------
// OUTPUT:
// * yhf = the disaggregated series
// * retal = a results tlist with:
//   - retal('meth') = 'Insee''s disaggregation'
//   - retal('y estim') = low frequency transformed series (that is
//   differentiated if residuals follow a RW, levle if not)
//   - retal('lf y') = low frequency series
//   - retal('x estim') = a (N x 1) vector of transformed low frequency
//   data
//   - retal('lf x') = a (N x 1) vector of low frequency data
//   - retal('nobs') = # of observations in the regression
//   - retal('resid estim') = a (n x 1) vector of regression
//   residuals
//   - retal('beta') = estimated coefficients of the low frequency
//   regression
//   - retal('tstat') = t stats
//   - retal('pvalue') = pvalue of the betas
//   - retal('prescte') = boolean indicating the presence or
//   absence of a constant in the regression
//   - retal('llike') = the log-likelihood
//   - retal('rho') = autcorrelation coefficient of residuals:
//  . if rho  = ]-1,1[ then the model is estimated in levels
//  . if rho = 1 then the model is estimated in differences
//   - retal('trend') = trend
//   . retal('trend') = 1 if retal('prescte') = %t and
//     rho = 1
//   . retal('trend') = 2 if retal('prescte') = %t and
//     rho ~= 1
//   . retal('trend') = 0 in other cases
//   - retal('y last values') = provisional value for y (and
//   therefore not used in estimation)
//   - retal('hf x') = a (n x k) matrix of exogenous high
//   frequency indicators
//   - retal('high freq') = a scalar, the indicators frequency
//   - retal('freq ratio') = a scalar, the ratio of high to low
//     frequency
//   - retal('aug lf x') = (N x l) matrix of regressors,
//   including the constant or trend if necessary
//   - retal('aug hf x') = (n x l) matrix of regressors,
//   including the constant or trend if necessary
//   - retal('lf yhat') = (N x 1) adjusted low frequency y
//   - retal('lf resid') = (N x 1) low frequency residual
//   - retal('forecasted lf resid') = low frequency residual extended
//   to the incomplete year with the estimated model
//   - retal('hf resid') = high frequency residual in TS
//   form
//   - retal('hf yhat') = high frequency adjusted y
//   - retal('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   - retal('namey') = name of the y variable
//   - retal('namex') = name of the x variables
//   ------------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_s = 4
grocer_alpha = 0.1
grocer_affich  = 1
grocer_bench = 'no'
grocer_mod = 'no'
grocer_prt = %t
grocer_ny_prov = 1
grocer_opt= -1
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      str1=part(varargin(grocer_i),1:1)
      str3=part(varargin(grocer_i),1:3)
      str5=part(varargin(grocer_i),1:5)
      if str1 == 's' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif str3 == 'mod' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif str3 == 'opt' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif str5 == 'bench' | str5 == 'alpha' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif part(varargin(grocer_i),1:7) == 'ny_prov'
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'noprint' then
         varargin(grocer_i)=null()
         grocer_prt=%f
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
[y,x,namey,namexos,prests,boundsvarb,sratio,boundsy]=explo_agreg(-1,grocer_namey,varargin(:))
 
if prests then
   grocer_s=date2fq(boundsvarb(1))
end
 
if grocer_s == 4 | grocer_s ==[4 , 1] then
   slit='q'
elseif grocer_s == 12 | grocer_s ==[12 , 1] then
   slit='m'
else
   error("bad frequency: only monthly and quarterly indicators allowed")
end
 
// provides the results from the regression of the vector y
// on the vector x
retal = etalcalinsee0(y,x,sratio,grocer_s,grocer_alpha,grocer_mod,grocer_ny_prov,grocer_opt)
 
// save the names, the bounds if the regression involves ts
retal(1)($+1) = 'prests'
retal(1)($+1) = 'namex'
retal(1)($+1) = 'namey'
 
retal('prests')=prests
retal('namex') =namexos
retal('namey') =namey
 
 
// transform the results into TS
boxd = date2num(boundsvarb(1))
boxf = date2num(boundsvarb(2))
yhf=tlist(['ts';'freq';'dates';'series'],retal('high freq'),[boxd:boxf]',retal('hf yhat'))
retal('hf yhat') = yhf
 
ts=yhf
ts('series')= retal('hf resid')
retal('hf resid') = ts
 
boyd =  boundsy(1)
retal('lf yhat') = reshape(retal('lf yhat'),boyd)
retal('lf resid') = reshape(retal('lf resid'),boyd)
retal('forecasted lf resid') = reshape(retal('forecasted lf resid'),boyd)
 
if grocer_prt then
   prtetalcal(retal)
   plt_etalcal(retal,grocer_bench)
end
 
endfunction
