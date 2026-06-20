function [vecout,step]=extrapna(vecin)
 
// PURPOSE: replace in a vector NA values by extrapolated ones;
// the function assumes that the values are regularly spaced
// ------------------------------------------------------------
// INPUT:
// * vecin = a real vector with %nan values
// ------------------------------------------------------------
// OUTPUT:
// * vecin = a real vector with no %nan values
// * step = the step between 2 cosnecutive values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nr,nc]=size(vecin)
// transform the input vector into a column
vecin=vecin(:)
[i2,j2]=find(~isnan(vecin))
 
if size(j2,2) < 2 then
   error('not enough non NA values in your vector')
end
 
step=(vecin(i2(2:$))-vecin(i2(1))) ./ (i2(2:$)-i2(1))'
 
// impose that the step between any non NA values is constant
if or(step(2:$) ~= step(2)) then
   error('step is not constant in your vector')
end
stepi=step(1)
 
if nr == 1 then
   vecout=vecin(i2(1))+[1-i2(1):nc-i2(1)]*stepi
else
   vecout=vecin(i2(1))+[1-i2(1):nr-i2(1)]'*stepi
end
 
endfunction
 
