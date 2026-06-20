function [y,res]=difonzo(grocer_Y,grocer_x,grocer_z,varargin)
 
 
// PURPOSE: Multivariate temporal disaggregation with transversal constraint
// -----------------------------------------------------------------------------
// INPUT:
// * grocer_Y = list of N vectors or ts or (NxM) matrix
//   ---> M series of low frequency data with N observations
// * grocer_x = (nxM) real or string matrix or list
//  ---> M series of high frequency data with n observations
// * grocer_z = (nx1) vector or ts ---> high frequency transversal constraint
// * grocer_d = objective function to be minimized: volatility of
//   - d=0 ---> levels
//   - d=1 ---> first differences
//   - d=2 ---> second differences
// * varargin = options to difonzo:
//   . the string 'divfq=n' where n is the number of high
//    frequency data points for each low frequency data points
//    (default: recovered from the data)
//   . the string 'ta=n' where n is the aggregation type:
//      n=-1 (default) ---> sum (flow)
//      n=0 ---> average (index)
//      n=i ---> i th element (stock) ---> interpolation
//   . typemod = model for the high frequency innvations
//            typemod='wn' ---> multivariate white noise (default)
//            typemod='rw' ---> multivariate random walk
// -----------------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res= a result tlist with:
//   - res('meth')        = 'Multivariate di Fonzo'
//   - res('ta')          = type of disaggregation
//   - res('nobs_lf')     = nobs of low frequency data
//   - res('nobs_hf')     = nobs of high-frequency data
//   - res('pred')        = number of extrapolations
//   - res('s')           = frequency conversion between low and high freq
//   - res('y')           = high frequency estimate
//   - res('y_lf')        = low frequency data
//   - res('indicator')   = high frequency indicators
//   - res('transversal') = high frequency indicators
//   - res('y_dt')        = high frequency estimate: standard deviation
//   - res('resid')       = high frequency residuals
//   - res('resid_U')     = low frequency residuals
//   - res('beta')        = estimated model parameters
//   - res('sd')          = standard deviation of the estimated model parameters
//   - res('namey')       = Name of the low frequency aggregate
//   - res('namex')       = Name of the high frequency indicators
//   - res('namez')       = Name of the high frequency transversal constraint
// -----------------------------------------------------------------------
// NOTE: Extrapolation is automatically performed when n>sN.
//       If n=nz>sN restricted extrapolation is applied.
//       Finally, if n>nz>sN extrapolation is perfomed in constrained
//       form in the first nz-sN observatons and in free form in
//       the last n-nz observations.
// -----------------------------------------------------------------------
// REFERENCE: di Fonzo, T.(1990)""""The estimation of M disaggregate time
// series when contemporaneous and temporal aggregates are known"""", Review
// of Economics and Statistics, vol. 72, n. 1, p. 178-182.
// -----------------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from Matlab programs written by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
// set defaults
grocer_calc_divfq=%t
grocer_ta=-1
grocer_typemod='wn'
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      varaux=strsubst(varargin(grocer_i),' ','')
      str6=part(varaux,[1:6])
      str3=part(varaux,[1:3])
      str8=part(varaux,[1:8])
      if str6 == 'divfq=' then
         execstr('grocer_'+varaux)
         varargin(grocer_i)=null()
         grocer_calc_divfq=%f
      elseif str3 == 'ta=' then
         execstr('grocer_'+varaux)
         varargin(grocer_i)=null()
      elseif str8 == 'typemod=' then
         grocer_typemod=part(varaux,9:length(varaux))
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
if grocer_calc_divfq then
   [Y,x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,grocer_divfq]=explo_agreg(grocer_ta,grocer_Y,grocer_x,grocer_z)
else
   [Y,x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,tmp_divfq]=explo_agreg(grocer_ta,grocer_Y,grocer_x,grocer_z)
end
 
if typeof(grocer_z) == 'string' then
   execstr('grocer_z='+grocer_z)
end
 
if typeof(grocer_z) ~= 'ts' then
   if typeof(grocer_z) == 'constant' then
      p=size(grocer_z,2)
      if p ~= 1 then
         error('3 rd arg -transversality constraint- should be a colum vector')
      end
   end
end
 
z=x(:,$)
x=x(:,1:$-1)
 
 
//--------------------------------------------------------
//       Preliminary checking
 
 
[y,res]=difonzo1(Y,x,z,grocer_ta,grocer_divfq,grocer_typemod)
res(1)($+1)='namey'
res('namey')=grocer_namendo
res(1)($+1)='namex'
res('namex')=grocer_namexos(1:$-1)
res(1)($+1)='namez'
res('namez')=grocer_namexos($)
endfunction
