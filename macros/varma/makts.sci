function xma = makts(xts,k)
 
// PURPOSE: Calculates a 2 sided k-period centered moving average
//---------------------------------------------------------
// INPUT:
// * xts  = time series
// * k   = size of the moving average filter
// -------------------------------------------------------------
// OUTPUT:
// * xma = filtered time series
// -------------------------------------------------------------
// Adapted and arranged by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Julien Matheron, Banque de France, centre de recherche.
 
[nargout,nargin] = argn(0)
if nargin < 2 then
  error('size of the moving average is missing')
end
 
if typeof(xts) == 'ts' then
  x=xts('series')
else
  error('This function works only with time series; for other format use ''mak'' function')
end
 
if (k/2 == int(k/2)) then
   w = [0;ones(k,1)]+[ones(k,1);0] ;
   incr = k;
else
   w = ones(k,1) ;
   incr = k-1;
end
s = w/sum(w) ;
 
xpadl = ones(floor(k/2),1).*.x(1,:)
xpadu = ones(floor(k/2),1).*.x($,:)
xpad = [xpadl ; x ; xpadu ] ;
xma = zeros(size(x,1),size(x,2)) ;
 
for i =1:size(x,1)
   xma(i,:) = s'*xpad(i:i+incr,:);
end
 
begin = num2date(xts('dates')(1),xts('freq')(1));
xma=reshape(xma,begin)
 
endfunction
 
