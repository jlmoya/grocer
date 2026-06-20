function ind = sortindc(x)
 
// PURPOSE: mimics gauss function sortindc: returns the sorted
// index of x.
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) vector of numeric data
// ------------------------------------------------------------
// OUTPUT:
// * ind = (N x 1) vector representing sorted index of x.
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(x) ~= 'string' then
   error('not a valid type: '+typeof(x))
end
 
if size(x,2) ~= 1 then
   error('input should be a column vector')
end
 
[junk,ind]=gsort(x,'g','i')
 
endfunction
 
