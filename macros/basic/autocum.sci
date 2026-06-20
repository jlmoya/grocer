function [seriein]=autocum(seriein,rho)
 
// PURPOSE: provides the vector (n x 1) or ts y such as:
// * y(t) = rho*y(t-1) + x(t)
// * y(t0) = x(t0) for the first observation t0
// ------------------------------------------------------------
// INPUT:
// * seriein = a (n x 1) or (1 x n) constant vector or a
// timeseries
// * rho = a constant
// ------------------------------------------------------------
// OUTPUT:
// * seriein = the vector (n x 1) or ts y such as:
// * y(t) = rho*y(t-1) + x(t)
// * y(t0) = x(t0) for the first observation t0
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
 
t=typeof(seriein)
 
select t
case 'constant' then
   [nl,nc]=size(seriein)
   if nc == 1 then
      nl=nc
   elseif nl ~= 1 then
      error('autocum applies only to vectors or ts, not to matrices')
   end
   for i=2:nl
      seriein(i)=seriein(i-1)*rho+seriein(i)
   end
case 'ts' then
   s=seriein('series')
   [nl,nc]=size(s)
   for i=2:nl
      s(i)=s(i-1)*rho+s(i)
   end
   seriein('series')=s
else
   error(t+' is not a valid type for argument #1 in autocum')
 
end
 
endfunction
 
