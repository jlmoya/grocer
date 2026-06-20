function [bounds_out]=lagbounds(bounds_in,l)
 
// PURPOSE: lag bounds in a regression
// ------------------------------------------------------------
// INPUT:
// * bounds_in = the original bounds
// * l = the lag (positive or negative, if you want to extend
//    bounds in the past)
// ------------------------------------------------------------
// OUTPUT:
// * bounds_out = the lagged bounds
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
bounds_num=date2num_m(bounds_in)
fq=date2fq(bounds_in(1))
nbounds=size(bounds_num,'*')
 
if l < 0 then
   bounds_num(1:2:nbounds-1)=bounds_num(1:2:nbounds-1)+l
   for i=nbounds/2:-1:2
      ind_suppr=find(bounds_num(2:2*i-2) >= bounds_num(2*i-1))
      if ~isempty(ind_suppr) then
         bounds_num([ind_suppr+1 2*i-1])=[]
      end
   end
 
else
   bounds_num(1:2:nbounds-1)=bounds_num(1:2:nbounds-1)+l
   i=nbounds/2
   while i >=1
      if bounds_num(2*i-1) > bounds_num(2*i) then
          bounds_num=bounds_num(1:2*i-2)
      end
      i=i-1
   end
 
end
bounds_out=num2date(bounds_num)
 
endfunction
