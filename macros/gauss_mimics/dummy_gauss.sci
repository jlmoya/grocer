function y=dummy_gauss(x,v)
 
// PURPOSE: mimic gauss function dummy: creates a set of dummy
// (0/1) variables by breaking up a variable into specified
// categories. The highest (rightmost) category is unbounded on
// the right
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) vector of data that is to be broken up into
//   dummy variables
// * v = (K-1)×1 vector specifying the K-1 breakpoints (these
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
y=[bool2s(x <= v(1)) ones(N,K)]
for i=2:K
   y(:,i)=bool2s(x > v(i-1) & x <=v(i))
end
y(:,K+1)=bool2s(x > v(K))
 
endfunction
 
