function z = atan2(y,x)
 
// PURPOSE: mimic Gauss function atan2: computes an angle from
// an x,y coordinate
// ------------------------------------------------------------
// INPUT:
// * y = (N x K) matrix or P-dimensional array where the last
//   two dimensions are N x K, the Y coordinate
// * x = (L x M) matrix or P-dimensional array where the last
//   two dimensions are (L x M), (E x E) conformable with y,
//   the X coordinate
// ------------------------------------------------------------
// OUTPUT:
// * z = max(N,L) by max(K,M) matrix or P-dimensional array
//   where the last two dimensions are max(N,L) by max(K,M)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
dims1=size(y)
ndims1=size(dims1,2)
dims2=size(x)
ndims2=size(dims2,2)
 
if ndims1 <= 2 & ndims2 <= 2 then
   [y,x]=resize(y,x)
else
   if ndims1 == 2 then
      dims1=[dims1 ones(1,ndims2-ndims1)]
   elseif ndims2 == 2 then
      dims2=[dims2 ones(1,ndims1-ndims2)]
   elseif ndims1 ~= ndims2 then
      error('hypermatrices should have the same dimensions')
   end
   dimsnew=max(dims1,dims2)
   x=aresize(x,dimsnew)
   y=aresize(y,dimsnew)
end
z=atan(y,x)
 
endfunction
 
