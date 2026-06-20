function y = submat(x,r,c)
 
// PURPOSE: mimic gauss function submat: Extracts a submatrix
// of a matrix, with the appropriate rows and columns given by
// the elements of vectors
// ------------------------------------------------------------
// INPUT:
// * x = (N x K) matrix
// * r = (L x M) matrix of row indices
// * c = (P x Q) matrix of column indices
// ------------------------------------------------------------
// OUTPUT:
// * y = (l*M x M*Q) matrix of column indices
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[nr,nc]=size(x)
[L,M]=size(r)
[P,Q]=size(c)
 
if L==1 & M==1 & r == 0 then
   r=1:nr
end
 
if P==1 & Q==1 & c == 0 then
   c=1:nr
end
 
y=x(r,c)
 
endfunction
