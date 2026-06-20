function []=pltacf(res,styleg)
 
// PURPOSE: plots results from a acf or pacf estimation
// ------------------------------------------------------------
// INPUT:
// * res = a tlist result ('acf, 'pacf', 'Ljung-Box',
//       'Box-Pierce' or 'Li McLeod')
// * styleg = style of the legend (between 1 and 7)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
meth0=res('meth')
if or(meth0 == ['acf' ; 'Ljung-Box' ; 'Box-Pierce' ; 'Li McLeod']) then
   meth0=''
elseif meth0 ==  'pacf' then
   meth0='partial '
else
   error('not an available result type: '+meth0)
end
tit=meth0+'autocorrelation for '+res('namey')
 
if res('prests') then
   tit=tit+' over the period '+joinstr(res('bounds'),'-')
end
 
wind=scf()
wind=wind.figure_id
 
[nargout,nargin]= argn(0)
select nargin
case 1 then
   if res('meth') == 'acf' then
      pltseries0([res(4) res(5) res(6)],0,...
      tit,string([1:size(res(4),1)]),wind,'leg='+meth0+'autocorrelation;'+string(100*(1-res('size')))+...
      ' % significance band','bars=[1 2 2]','style=[1 2 2]','color=[1 2 2 ]','x0=0','styleg=7')
   else
      pltseries0([res(4) res(5) res(6)],0,...
      tit,string([1:size(res(4),1)]),wind,'leg='+meth0+'autocorrelation;'+string(100*(1-res('size')))+...
      ' % significance band','bars=[1 2 2]','style=[1 2 2]','color=[1 2 2 ]','x0=0','styleg=7')
   end
else
   pltseries0([res(4) res(5) res(6)],0,...
   tit,string([1:size(res(4),1)]),wind,'leg='+meth0+'autocorrelation;'+string(100*(1-res('size')))+...
   ' % significance band','bars=[1 2 2]','style=[1 2 2]','color=[1 2 2 ]','x0=0',styleg)
end
 
endfunction
