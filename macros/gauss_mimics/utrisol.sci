function x = utrisol(b,U)
 
// PURPOSE: mimics gauss function utrisol: Computes the
// solution of Ux = b where U is an upper triangular matrix
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
[P1,P2] = size(U);
 
if P1~=P2 then
   error('arg 2 should be a squared matrix')
end
 
if P1~=P then
   error('args 1 and 2 have not the same # or rows')
end
 
if or(U ~= triu(U)) then
   error('2nd arg is not an upper triangular matrix')
end
 
x = [ zeros(P-1,k) ; b(P,:)/U(P,P) ]
for j=P-1:-1:1
   x(j,:)=(b(j,:)-U(j,j+1:P)*x(j+1:P,:))/U(j,j)
end
 
endfunction
