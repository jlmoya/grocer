function z=%hm_atan(y,x)
 
// PURPOSE: define atan for hypermatrices
// ------------------------------------------------------------
// INPUT:
// * y = an hypermatrix
// * x = an hypermatrix (optional)
// ------------------------------------------------------------
// OUTPUT:
// * z = an hypermatrix of the same size
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   z=matrix(atan(y(:)),size(y))
elseif size(y) == size(x) then
   z=matrix(atan(y(:),x(:)),size(x))
else
   error('hypermatrices have not the same size')
end
 
endfunction
