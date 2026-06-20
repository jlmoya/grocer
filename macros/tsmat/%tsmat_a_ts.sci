function [tsmat1]=%tsmat_a_ts(tsmat1,ts2)
 
// PURPOSE: operates the addition of a tsmat with a timeseries;
// the overloading capability of scilab allows then one to
// write tsmat1+ts2 to do the addition
// ------------------------------------------------------------
// INPUT:
// * tsmat1 = a tlist of type tsmat
// * ts2 = a time series
// ------------------------------------------------------------
// OUTPUT:
// * tsmat1 = the sum of a tsmat and a time series
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux 20008
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
f1=tsmat1('freq')
if f1 ~= ts2('freq') then
   error('timeseries have not the same frequency')
end
 
d1=tsmat1('dates')
d2=ts2('dates')
s1=tsmat1('series')
s2=ts2('series')
 
d1f=d1(1)
d1l=d1(size(d1,1))
d2f=d2(1)
d2l=d2(size(d2,1))
 
// determines the commun time span of the 2 series
datfirst=max(d1f,d2f)
datlast=min(d1l,d2l)
dataux=[datfirst:datlast]'
 
// for the sake of speed, fill the timeseries tsmat1 with the
// values of the sum
tsmat1('dates')=[datfirst:datlast]'
 
tsmat1('series')=s1(datfirst-d1f+1:datlast-d1f+1,:)+...
             ones(1,size(s1,2)).*.s2(datfirst-d2f+1:datlast-d2f+1)
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   if size(ts2(1),1) > 5 then
      if ts2('comment') ~= ' ' then
         tsmat('names') = tsmat1('names')+' + '+ts2('comment')
      else
         tsmat('names') = tsmat1('names')+' + ts'
      end
   else
      tsmat('names') = tsmat1('names')+' + ts'
   end
 
end
 
 
if or(tsmat1(1) == 'comments') then
   tsmat1('comments')=emptystr(size(tsmat1('names'),1),1)
end
 
endfunction
