function a = band(y,n)
 
// PURPOSE: mimic Gauss function band: extracts bands from a
// symmetric banded matrix
// ------------------------------------------------------------
// INPUT:
// * y = a (K x K) symmetric banded matrix
// * n = scalar, number of subdiagonals
// ------------------------------------------------------------
// OUTPUT:
// * a = (K x (N+1)) matrix, 1 subdiagonal per column
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ny=size(y,1)
a=zeros(ny,n+1)
for i=0:n
   a(i+1:ny,n+1-i)=diag(y,i)
end
 
endfunction
 
