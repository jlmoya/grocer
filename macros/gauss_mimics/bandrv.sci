function y = bandrv(a)
 
// PURPOSE: mimic Gauss function bandrv: creates a symmetric
// banded matrix, given its compact form
// ------------------------------------------------------------
// INPUT:
// * a = a (K x N) compact form matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = a (K x K) symmetrix banded matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[n,k]=size(a)
y=diag(a(:,k))
for i=1:k-1
   y=y+diag(a(k-i+1:n,i),-i)+diag(a(k-i+1:n,i),i)
end
 
endfunction
 
