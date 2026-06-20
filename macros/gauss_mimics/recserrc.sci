function [z] = recserrc(x,y)
 
// PURPOSE: mimics gauss function recserrc: computes a
// recursive series involving division
// ------------------------------------------------------------
// INPUT:
// * x = (1 x K) or (K x 1) vector
// * y = (N x K) matrix
// ------------------------------------------------------------
// OUTPUT:
// z = N x K) matrix in which each column is a series generated
//     by a recursion of the form:
//     y(1) = x mod z(1), x = trunc(x/z(1))
//     y(2) = x mod z(2), x = trunc(x/z(2))
//     y(3) = x mod z(3), x = trunc(x/z(3))
//       .
//       .
//       .
//    y(n) = x mod z(n)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
x = vec2col(x);
rx = size(x,1);
[n,k] = size(z);
k = size(z,2);
 
if rx ~= k then
  error(" Number of elements in x must be the same as the number of columns in z.");
end;
 
w = [fix(x' ./ z(1,:)) ; zeros(n-1,k)]
for i=2:n
   w(i,:)=fix(w(i-1,:) ./z(i,:))
end
y = [pmodulo(x',z(1,:)) ; pmodulo(w(1:$-1,:),z(2:$,:))]
 
endfunction
