function [scale,miny,maxy]=yscale(y,just_scale)
 
// PURPOSE: determines from the y values of the values of the
// y scale
// ------------------------------------------------------------
// INPUT:
// * y = the vector of values of the scale
// ------------------------------------------------------------
// OUPTUT:
// * scale = the y scale
// * miny = minimum of y values
// * maxy = maximum of y values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
 
y=y(~isnan(y))
if and(y == real(y)) then
   y=real(y)
else
   error('y is not real')
end
 
miny=min(y)
maxy=max(y)
 
if miny == maxy then
   if miny == 0 then
      y=[0;1]
      maxy=1
   elseif miny < 0 then
      y=[1.2*miny ;0]
      maxy=0
      miny=1.2*miny
   else
      y=[0; maxy]
      maxy=1.2*maxy
   end
 
end
// determine the range of the y axis:
ordy=floor(log10(maxy-miny))
 
// dermination of the scale with respect to the difference between
// the lower and upper significative number
ymax=floor(max(y/10^ordy))
ymax=ymax+bool2s(maxy ~= ymax*10^ordy)
ymin=floor(min(y/10^ordy))
 
if ymax-ymin > 5 then
   nint=1
else
   ymax=floor(max(y*2/10^ordy))/2
   ymax=ymax+bool2s(maxy ~= ymax*10^ordy)/2
   ymin=floor(min(y*2/10^ordy))/2
   if ymax-ymin > 2.5 then
      nint=2
   else
      ymax=floor(max(y*5/10^ordy))/5
      ymax=ymax+bool2s(maxy ~= ymax*10^ordy)/5
      ymin=floor(min(y*5/10^ordy))/5
      if ymax-ymin > 1 then
         nint=5
      else
         nint=10
         ymax=floor(max(y*10/10^ordy))/10
         ymax=ymax+bool2s(maxy ~= ymax*10^ordy)/10
         ymin=floor(min(y*10/10^ordy))/10
      end
   end
end
 
scale=[ymin*nint-bool2s(just_scale):ymax*nint+bool2s(just_scale)]/nint*10^ordy
 
endfunction
