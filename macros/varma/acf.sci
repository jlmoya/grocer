function [resacf]=acf(grocer_namey,varargin)
 
// PURPOSE: find sample autocorrelation coefficients
//---------------------------------------------------
// INPUT:
// * namey = a time series, a real (nx1) vector or a string equal to the name of a time series or a (nx1) real vector between quotes
// * argi = (optional) string arguments that can be:
//   - 'noplt' if the user does not want to plot the autocorrelation coefficients
//   - 'm=xx' where xx is the number of calculated coefficients (default: floor(size(grocer_y,'*')/4)
//   - 'size=xx' where xx is the size of the confidence band (default: 0.05)
//---------------------------------------------------
// OUTPUT:
// resacf = a tlist with
//   . resacf('meth')   = 'acf'
//   . resacf('y')      = values of the input variable
//   . resacf('acf')   = autocorrelation coeffcients
//   . resacf('acf_l') = low bound of the confidence interval
//   . resacf('acf_u') = upper bound of the confidence interval
//   . resacf('size') = size of the confidence band
//   . resacf('namey') = name of variable
//   . resacf('prests') = %t if variable is a ts
// --------------------------------------------------
// Copyright INRIA/ Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_plt=%t
grocer_size=0.05
grocer_styleg=[]
grocer_dropna=%f
 
nargin=length(varargin)
for grocer_i=1:nargin
   if typeof(varargin(grocer_i)) == 'string' then
      if varargin(grocer_i) == 'noplt' then
         grocer_plt=%f
      elseif part(varargin(grocer_i),1:2) == 'm=' then
         execstr('grocer_'+varargin(grocer_i))
      elseif part(varargin(grocer_i),1:5) == 'size=' then
         execstr('grocer_'+varargin(grocer_i))
      elseif part(varargin(grocer_i),1:7) == 'styleg=' then
         execstr('grocer_'+varargin(grocer_i))
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
      end
   else
      error(typeof(varargin(grocer_i))+' is not authorized in acf for entry '+...
      string(grocer_varargin(grocer_i)))
   end
end
 
[y,namey,prests,boundsvarb,nonna]=explone(grocer_namey,[],'variable',%t,grocer_dropna)
if ~exists('grocer_m','local')
   grocer_m=size(y,'*')/4
end
resacf=acf1(y,grocer_m,grocer_size)
resacf(1)($+1)='namey'
resacf(1)($+1)='prests'
resacf($+1)=namey
resacf($+1)=prests
 
if prests then
   resacf(1)($+1) = 'bounds'
   resacf('bounds')=boundsvarb
end
 
if grocer_plt then
// the user has not entered 'noplt' as an argument
  if grocer_styleg == [] then
     pltacf(resacf)
  else
     pltacf(resacf,'styleg='+string(grocer_styleg))
  end
end
 
endfunction
 
