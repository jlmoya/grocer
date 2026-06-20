function [out]=matmul(x,y)
 
// PURPOSE:  mimics gauss operation .*: perform matrix
// multiplication even if matrices are not of the same
// dimension, but are row or column compatible
// ------------------------------------------------------------
// INPUT:
// x,y = two matrices (not of the same dimension
//                 but are row or column compatible)
// ------------------------------------------------------------
// OUTPUT:
// out = x.*y where x and y are row or column compatible
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(x) == 'array' then
   [rx,cx] = size(x('value'));
else
   [rx,cx] = size(x);
end
 
if typeof(y) == 'array' then
   [ry,cy] = size(y('value'));
else
   [ry,cy] = size(y);
end
 
if rx ~= ry then
   if ry == 1 then
      y=ones(rx,1) .*. y
 
   elseif rx == 1 then
      x=ones(ry,1) .*. x
 
   else
      error('rows are not conformable')
   end
end
 
if cx ~= cy then
 
   if cy == 1 then
      y=y .*. ones(1,cx)
 
   elseif cx == 1 then
      x=x .*. ones(1,cy)
 
   else
      error('cols are not conformable')
   end
end
 
out=x .* y
 
 
endfunction
 
