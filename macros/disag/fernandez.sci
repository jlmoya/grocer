function [y,res]=fernandez(grocer_namey,varargin)
 
// PURPOSE: Temporal disaggregation using the Fernandez method
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
//   string equal to the name of a time series or a (nx1) real
//   vector between quotes, representing the low frequency data
//   that must be desaggregated
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxk) matrix
//   . a string matrix whose elements represent the names of a
//     time series or a (nx1) real vector between quotes
//   . a list of such objects
//   . the string 'divfq=n' where n is the number of high
//    frequency data points for each low frequency data points
//    (default: recovered from the data)
//   . the string 'ta=n' where n is the aggregation type:
//      n=-1 (default) ---> sum (flow)
//      n=0 ---> average (index)
//      n=i ---> i th element (stock) ---> interpolation
// ------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res = a results tlist with:
//   - res('meth')      ='Fernandez'
//   - res('ta')        = type of disaggregation
//   - res('nobs_lf')   = nobs. of low frequency data
//   - res('nobs_hf')   = nobs. of high-frequency data
//   - res('pred')      = number of extrapolations
//   - res('s')         = frequency conversion between low and high freq.
//   - res('p')         = number of regressors (including intercept)
//   - res('y')         = high frequency estimate
//   - res('y_lf')      = low frequency data
//   - res('indicator') = high frequency indicators
//   - res('y_dt')      = high frequency estimate: standard deviation
//   - res('y_up')      = high frequency estimate: sd + sigma
//   - res('y_lo')      = high frequency estimate: sd - sigma
//   - res('resid')     = high frequency residuals
//   - res('resid_lf)   = low frequency residuals
//   - res('beta')      = estimated model parameters
//   - res('sd')        = estimated model parameters: standard deviation
//   - res('tstat')     = estimated model parameters: t ratios
//   - res('pvalue')    = pvalue of the betas
//   - res('llike')     = Log-likelihood at the estimated parameters
//   - res('aic')       = Information criterion: AIC
//   - res('bic')       = Information criterion: BIC
//   - res('namey')     = Name of the low frequency disaggregated data
//   - res('namex')     = Name of the indicators
//   - res('prests')    = a boolean indicating the presence or
//     absence of a time series in the regression
//   - res('bounds')    = if there is a timeseries in the
//     regression, the bounds of the regression
// ------------------------------------------------------------
// LIBRARY: aggreg
// ------------------------------------------------------------
// SEE ALSO: chowlin, litterman, td_plot, td_print
// ------------------------------------------------------------
// REFERENCE: Fernández, R.B.(1981)""""Methodological note on the
// estimation of time series"""", Review of Economic and Statistics,
// vol. 63, n. 3, p. 471-478.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from Matlab programs written
// by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
 
// set defaults
grocer_calc_divfq=%t
grocer_ta=-1
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      varaux=strsubst(varargin(grocer_i),' ','')
      str6=part(varargin(grocer_i),[1:6])
      str8=part(varargin(grocer_i),[1:8])
      str3=part(varargin(grocer_i),[1:3])
      if str6 == 'divfq=' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
         grocer_calc_divfq=%f
      elseif str3 == 'ta=' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif varaux == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
if grocer_calc_divfq then
   [Y,x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,grocer_divfq]=explo_agreg(grocer_ta,grocer_namey,varargin(:))
else
   [Y,x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,tmp_divfq]=explo_agreg(grocer_ta,grocer_namey,varargin(:))
   if grocer_divfq ~= tmp_divfq then
    warning('frequency conversion divfq ('+string(grocer_divfq)+') doesn''t macth: it has been replaced by '+string(tmp_divfq))
    grocer_divfq = tmp_divfq
   end
end
 
[y,res]=fernandez1(Y,x,grocer_ta,grocer_divfq)
 
res(1)($+1)='namey'
res('namey')=grocer_namendo
res(1)($+1)='namex'
res('namex')=grocer_namexos
res(1)($+1) = 'prests'
res('prests') = grocer_prestshf
 
if grocer_prestshf then
   res(1)($+1) = 'bounds'
   res('bounds') = grocer_boundshf
   y=reshape(y,grocer_boundshf(1))
   res('y_hf')=y
   res('y_dt')=reshape(res('y_dt'),grocer_boundshf(1))
   res('y_up')=reshape(res('y_up'),grocer_boundshf(1))
   res('y_lo')=reshape(res('y_lo'),grocer_boundshf(1))
end
 
if grocer_prt then
   prtdisag(res,%io(2))
end
endfunction
