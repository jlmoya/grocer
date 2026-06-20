function xma = maokts(xts,k)
 
// PURPOSE: Calculates a 1 sided k-period moving average
//---------------------------------------------------------
// INPUT:
// * xts = original matrix
// * k   = size of the moving average filter
// -------------------------------------------------------------
// OUTPUT:
// * xma = filtered time series
// -------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin < 2 then
  error('size of the moving average is missing')
end
 
if typeof(xts) == 'ts' then
  x=xts('series')
else
  error('This function works only with time series; for other format use ''maok'' function')
end
 
xrep= [ones(k-1,1).*.x(1,:);x];
xma = zeros(size(x,1),size(x,2)) ;
for i =1:size(x,1)
   xma(i,:) = mean0(xrep(i:i+(k-1),:),1);
end
 
begin = num2date(xts('dates')(1),xts('freq')(1));
xma=reshape(xma,begin)
 
endfunction
 
