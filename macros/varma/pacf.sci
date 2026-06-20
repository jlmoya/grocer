function [respacf]=pacf(grocer_namey,varargin)
 
// PURPOSE: find sample partial autocorrelation coefficients
//---------------------------------------------------
// INPUT:
// * namey = a time series, a real (nx1) vector or a string equal to the name of a time series or a (nx1) real vector between quotes
// * argi = (optional) string arguments that can be:
//   - 'noplt' if the user does not want to plot the partial autocorrelation coefficients
//   - 'm=xx' where xx is the number of calculated coefficients (default: floor(size(grocer_y,'*')/4)
//   - 'size=xx' where xx is the size of the confidence band (default: 0.05)
//---------------------------------------------------
// OUTPUT:
// respacf = a tlist with
//   . respacf('meth')   = 'pacf'
//   . respacf('y')      = values of the input variable
//   . respacf('pacf')   = partial autocorrelation coeffcients
//   . respacf('pacf_l') = low bound of the confidence interval
//   . respacf('pacf_u') = upper bound of the confidence interval
//   . respacf('size') = size of the confidence band
//   . respacf('namey') = name of variable
//   . respacf('prests') = %t if variable is a ts
// --------------------------------------------------
// Copyright Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb]=...
exploy(grocer_namey)
if grocer_prests then
   grocer_y=ts2vec(grocer_y,grocer_boundsvarb)
end
 
// set defaults
grocer_plt=%t
grocer_size=0.05
grocer_m=size(grocer_y,'*')/4
grocer_styleg=[]
 
nargin=length(varargin)
for grocer_i=1:nargin
   if varargin(grocer_i) == 'noplt' then
      grocer_plt=%f
   elseif typeof(varargin(grocer_i)) == 'string' then
      if part(varargin(grocer_i),1:2) == 'm=' then
         execstr('grocer_'+varargin(grocer_i))
      elseif part(varargin(grocer_i),1:5) == 'size=' then
         execstr('grocer_'+varargin(grocer_i))
      elseif part(varargin(grocer_i),1:7) == 'styleg=' then
         execstr('grocer_'+varargin(grocer_i))
      end
   else
      error(typeof(varargin(grocer_i))+' is not authorized in pacf for entry '+...
      string(grcoer_varargin(grocer_i)))
   end
end
 
n = size(grocer_y,1);
x = zeros(grocer_m,1);
npm = n+grocer_m;
 
// put y in deviations from mean form
e = zeros(npm,1);
e(1:n,1) = grocer_y-mean0(grocer_y)
 
f = crlag(e,npm);
 
for i = 1:grocer_m
  parti = f'*e/(f'*f);
  apart = -parti;
  tmp = e;
  e = tmp+apart*f;
  f = f+apart*tmp;
  f = crlag(f,npm);
  x(i) = parti;
end
 
bandsize=cdfnor("X",0,1,grocer_size/2,1-grocer_size/2)
ul = bandsize*(1/sqrt(n)*ones(grocer_m,1));
ll = -bandsize*(1/sqrt(n)*ones(grocer_m,1));
 
respacf=tlist(['results';'meth';'y';'pacf';'pacf_l';'pacf_u';...
'size';'namey';'prests'],...
'pacf',grocer_y,x,ll,ul,grocer_size,grocer_namey,grocer_prests)
 
if grocer_prests then
   respacf(1)($+1) = 'bounds'
   respacf('bounds')=grocer_boundsvarb
end
 
if grocer_plt then
// the user has not entered 'noplt' as an argument
  if grocer_styleg == [] then
     pltacf(respacf)
  else
     pltacf(respacf,'styleg='+string(grocer_styleg))
  end
end
 
endfunction
 
