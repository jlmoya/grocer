function [xun]=undrift(x)
 
// PURPOSE: This function removes the drift or a linear time trend from a time series using the formula
//   drift = (x(T) - x(1)) / (T-1).
// ------------------------------------------------------------
// INPUT:
// x =
// - a data matrix x where columns represent different variables
// , x is (T x # variables).
// - or a ts
// ------------------------------------------------------------
// OUPTUT:
// xun =
// - if x is a a matrix, then a data matrix same size as x with
// a different drift/trend removed from each variable.
// - a ts with drift/trend removed if x is a ts
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
select typeof(x)
case 'ts' then
   s=series(x)
   T=size(s,1)
   xun=x
   xun('series')=s-(s(T)-s(1))/(T-1);
 
case 'constant' then
   [T,nvars] = size(x);
   xun = zeros(T,nvars);
   dd = (0:T-1)';
   for ivar = 1:nvars
      drift = (x(T,ivar)-x(1,ivar))/(T-1);
      xun(:,ivar) = x(:,ivar)-dd*drift;
   end
 
else
   error(typeof(x)+' is not allowed in undrift')
end
 
endfunction
 
