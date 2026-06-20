function x = lusol(b,L,U)
 
// PURPOSE: mimic gauss function lusol: Computes the solution
// of LUx = b where L is a lower triangular matrix and U is
// an upper triangular matrix
// ------------------------------------------------------------
// INPUT:
// * b = a (P x k) matrix
// * L = a (P x P) lower triangular matrix
// * U = a (P x P) upper triangular matrix
// ------------------------------------------------------------
// OUTPUT:
// * x = a (P x k) matrix, soluion of L*U*x = b
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[P,k] = size(b);
[P1,k1] = size(L);
[P2,k2] = size(U);
 
if P1~=k1 then
   error('arg 2 should be a squared matrix')
end
 
if P2~=k2 then
   error('arg 3 should be a squared matrix')
end
 
if P1~=P | P2~=P then
   error('args have not the same # or rows')
end
 
if or(L ~= tril(L)) then
   error('2nd arg is not a lower triangular matrix')
end
 
if or(U ~= triu(U)) then
   error('3rd arg is not an upper triangular matrix')
end
 
iL=L\eye(P1,P1)
iU=U\eye(P1,P1)
x=iU*iL*b
 
endfunction
