function y = polymat(x,p)
 
// PURPOSE: mimic gauss function polymat: takes the powers
// 1 to p of matrix x and sticks them in one matrix
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) real or complex matrix
// * p = a scalar
// ------------------------------------------------------------
// OUTPUT:
// * y = a ((N x (k*p)) matrix, containing powers of the
// elements of x from 1 to p. The first K columns will contain
// first powers, the second K columns second powers, and so on.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[N,k]=size(x)
y=ones(N,p*k)
for i=1:p
   y(:,k*(i-1)+[1:k])=x .^ i
end
 
endfunction
