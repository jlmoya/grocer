function xma = mak(x,k)
 
// PURPOSE: Calculates a 2 sided k-period centered moving average
//---------------------------------------------------------
// INPUT:
// * x = matrix of data
// * k = size of the moving average filter
// -------------------------------------------------------------
// OUTPUT:
// * xma = filtered data
// -------------------------------------------------------------
// Adapted and arranged by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Julien Matheron, Banque de France, centre de recherche.
 
[nargout,nargin] = argn(0)
if nargin < 2 then
  error('size of the moving average is missing')
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
xpadall = [xpadl ; x ; xpadu ] ;
xma = zeros(size(x,1),size(x,2)) ;
 
for i =1:size(x,1)
   xma(i,:) = s'*xpadall(i:i+incr,:);
end
 
 
endfunction
 
