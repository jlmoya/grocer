function y=dummybr(x,v)
 
// PURPOSE: mimic gauss function dummybr: creates a set of
// dummy (0/1) variables. The highest (rightmost) category is
// bounded on the right
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) vector of data that is to be broken up into
//   dummy variables
// * v = (K x 1) vector specifying the K-1 breakpoints (these
//   must be in ascending order) that determine the K
//   categories to be used. These categories should not overlap
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) matrix containing the K dummy variables
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
N=size(x,1)
K=size(v,1)
y=[bool2s(x <= v(1)) ones(N,K-1)]
for i=2:K
   y(:,i)=bool2s(x > v(i-1) & x <=v(i))
end
 
endfunction
 
