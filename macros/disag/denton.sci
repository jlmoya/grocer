function [y,res]=denton(grocer_Y,grocer_x,grocer_z,grocer_d,varargin)
 
// PURPOSE: Multivariate temporal disaggregation with transversal constraint
// -----------------------------------------------------------------------------
// INPUT:
// * grocer_Y = a (NxM) matrix, a list of M vectors or ts or a string vector
//   representing names such objects
//   ---> M series of low frequency data with N observations
// * grocer_x = a (nxM) matrix, a list of M vectors or ts or a string vector
//   representing names such objects
//  ---> M series of high frequency data with n observations
// * grocer_z = a (nx1) vector or a ts
//  ---> high frequency transversal constraint
// * grocer_d = objective function to be minimized: volatility of
//   -  - d=0 ---> levels
//   -  - d=1 ---> first differences
//   -  - d=2 ---> second differences
// * varargin = options to denton:
//   . the string 'divfq=n' where n is the number of high
//    frequency data points for each low frequency data point
//    (default: recovered from the data)
//   . the string 'ta=n' where n is the aggregation type:
//      n=-1 (default) ---> sum (flow)
//      n=0 ---> average (index)
//      n=i ---> i th element (stock) ---> interpolation
// -----------------------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res = a results tlist with
//   - res('meth')         = 'Multivariate Denton';
//   - res('ta')           = Type of disaggregation
//   - res('nobs_lf')      = Number of low frequency data
//   - res('nobs_hf')      = Number of high frequency data
//   - res('pred')         = Number of extrapolations (=0 in this case)
//   - res('s')            = Frequency conversion
//   - res('diff')         = Degree of differencing
//   - res('y')            = High frequency estimate
//   - res('y_lf')         = low frequency data
//   - res('indicator')    = high frequency indicators
//   - res('tanvsersal')   = data for the transversal constraint
//   - res('namey')        = Name of the low frequency aggregate
//   - res('namex')        = Name of the high frequency indicators
//   - res('namez')        = Name of the high frequency transversal constraint
// -----------------------------------------------------------------------
// REFERENCE: di Fonzo, T(' (1994) """"Temporal disaggregation of a system of
// time series when the aggregate is known: optimal vs(' adjustment methods"""",
// INSEE-Eurostat Workshop on Quarterly National Accounts, Paris, december
// -----------------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from a Matlab program written
// by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
// set defaults
grocer_calc_divfq=%t
grocer_ta=-1
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      varaux=strsubst(varargin(grocer_i),' ','')
      str6=part(varargin(grocer_i),[1:6])
      str3=part(varargin(grocer_i),[1:3])
      if str6 == 'divfq=' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
         grocer_calc_divfq=%f
      elseif str3 == 'ta=' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
if grocer_calc_divfq then
   [Y,x,grocer_namendo,grocer_namexos,grocer_divfq]=explo_agreg(grocer_ta,grocer_Y,grocer_x,grocer_z)
else
   [Y,x,grocer_namendo,grocer_namexos]=explo_agreg(grocer_ta,grocer_Y,grocer_x,grocer_z)
end
 
if typeof(grocer_z) ~= 'string' then
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
 
[N,M] = size(Y);
[n,m] = size(x);
[nz,mz] = size(z);
 
if M ~= m | n ~= grocer_divfq*N | n ~= nz | mz ~= 1 then
  write(%io(2),'size(Y): '+joinstr(string(size(Y)),' x '),'(a)')
  write(%io(2),'size(x): '+joinstr(string(size(x)),' x '),'(a)')
  write(%io(2),'size(z): '+joinstr(string(size(z)),' x '),'(a)')
  error(' *** INCORRECT DIMENSIONS *** ');
else
  clear('m','nz','mz');
end
 
[y,res]=denton1(Y,x,z,grocer_d,grocer_ta,grocer_divfq)
res(1)($+1)='namey'
res('namey')=grocer_namendo
res(1)($+1)='namex'
res('namex')=grocer_namexos
res(1)($+1)='namez'
res('namez')=grocer_namexos
endfunction
