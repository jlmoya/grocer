function x = ltrisol(b,L)
 
// PURPOSE: mimic gauss function ltrisol: Computes the
// solution of Lx = b where L is a lower triangular matrix
// ------------------------------------------------------------
// INPUT:
// * b = a (P x k) matrix
// * L = a (P x P) lower triangular matrix
// ------------------------------------------------------------
// OUTPUT:
// * x = a (P x k) matrix, soluion of Lx = b
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[P,k] = size(b);
[P1,P2] = size(L);
 
if P1~=P2 then
   error('arg 2 should be a squared matrix')
end
 
if P1~=P then
   error('args 1 and 2 have not the same # or rows')
end
 
if or(L ~= tril(L)) then
   error('2nd arg is not a lower triangular matrix')
end
 
x = [b(1,:)/L(1,1) ; zeros(P-1,k)]
for j=2:P
   x(j,:)=(b(j,:)-L(j,1:j-1)*x(1:j-1,:))/L(j,j)
end
 
endfunction
