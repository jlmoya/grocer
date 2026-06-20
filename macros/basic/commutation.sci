function [K]=commutation(m,n)
 
// PURPOSE: given any (m X n) matrix A, return the (mn X mn) K
//          matrix such that: vec(A')=K*vec(A).
// ------------------------------------------------------------
// INPUT:
// * m = # of rows of matrix A.
// * n = # of columns of matrix A.
// ------------------------------------------------------------
// OUTPUT:
// K = comutation matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated to scilab from:
// Marco Aiolfi
// maiolfi@iol.it
// Bocconi University and Banca Intesa, Milan
 
[nargout,nargin] = argn(0)
if nargin==1 then
  n = m;
end
 
// a=normrnd(1,1,m,n); this was replaced by LeSage
a = rand(m,n,'n')+ones(n,m);
x = a(:);
puto = a';
y = puto(:);
z = x*y';
 
K = zeros(m*n,m*n);
for i = 1:m*n
  for j = 1:m*n
    if sqrt(z(i,j))==abs(x(i)) then
      K(i,j) = 1;
    else
      K(i,j) = 0;
    end
  end
end
 
endfunction
 
