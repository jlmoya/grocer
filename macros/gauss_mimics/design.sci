function y = design(x)
 
// PURPOSE: mimics gauss function design: creates a design
// matrix of 0’s and 1’s from a column vector of numbers
// specifying the columns in which the 1’s should be placed
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) vector
// ------------------------------------------------------------
// OUTPUT:
// * y = a (N x k) matrix where k = max(x); each row of y will
// contain a single 1, and the rest 0’s. The one in the ith
// row will be in the round(x[i,1]) column.
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
n=size(x(:),1)
k=max(x)
y=zeros(n,k)
for i=1:n
   y(i,round(x(i)))=1
end
 
 
endfunction
 
