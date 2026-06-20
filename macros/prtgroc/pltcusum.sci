function []=pltcusum(res,siz,output)
 
// PURPOSE: plots the results of the cusum test
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of function cusumb or cusumf
// * siz= the chosen size dor the test (0.01, 0.05 or 0.1)
// * output = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
[nargout,nargin]=argn(0)
select nargin
case 1 then
   siz=0.05
   output=%io(2)
case 2 then
   output=%io(2)
end
 
s=string(100*(1-siz))
 
w=res('cusum')
ch='wl=res(''cusum_l'+s+''')'
execstr(ch)
ch='wu=res(''cusum_u'+s+''')'
execstr(ch)
ti1=res('dir')+' cusum test'
 
w2=res('cusums')
ch='w2l=res(''cusums_l'+s+''')'
execstr(ch)
ch='w2u=res(''cusums_u'+s+''')'
execstr(ch)
ti2=res('dir')+' cusumq test'
 
co='color=[1 2 2]'
le='leg=[test statistic;'+s+' % confidence band'
 
if res('prests') then
   bo=res('bounds')
   for i=1:size(bo,1)/2
      d1=date2num(bo(i*2-1))
      xscale0=num2date([d1:d1+diff_date(bo(2*i),...
              bo(2*i-1))],date2fq(bo(i*2-1)))
      nobs=size(xscale0,2)
   end
else
   xscale0 = [1:nobs]
end
 
pltseries0([w,wl,wu],[],ti1,string(xscale0),1,le,co,'styleg=4','style=[1 2 2]')
 
if res('dir') == 'backward' then
   pltseries0([w2,w2l,w2u],0,ti2,string(xscale0),2,le,co,'styleg=3','style=[1 2 2]')
else
   pltseries0([w2,w2l,w2u],0,ti2,string(xscale0),2,le,co,'styleg=4','style=[1 2 2]')
end
 
endfunction
