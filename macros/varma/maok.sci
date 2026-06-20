function xma = maok(x,k)
 
// PURPOSE: Calculates a 1 sided k-period moving average
//---------------------------------------------------------
// INPUT:
// * x   = original matrix
// * k   = size of the moving average
// -------------------------------------------------------------
// OUTPUT:
// * xma = filtered data
// -------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin < 2 then
  error('size of the moving average is missing')
end
 
xrep = [ones(k-1,1).*.x(1,:);x];
xma = zeros(size(x,1),size(x,2)) ;
for i =1:size(x,1)
   xma(i,:) = mean0(xrep(i:i+(k-1),:),1);
end
 
endfunction
 
