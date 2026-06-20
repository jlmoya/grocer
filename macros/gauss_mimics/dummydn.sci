function y=dummydn(x,v,p)
 
// PURPOSE: mimic gauss function dummybr: creates a set of
// dummy (0/1) variables by breaking up a variable into
// specified categories. The highest (rightmost) category is
// unbounded on the right, and aspecified column of dummies is
// dropped
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) vector of data that is to be broken up into
//   dummy variables
// * v = ((K-1) x 1) vector specifying the K-1 breakpoints (these
//   must be in ascending order) that determine the K
//   categories to be used. These categories should not overlap
// * p = positive integer in the range [1,K], specifying which
//   column should be dropped in the matrix of dummy variables
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x (K-1)) matrix containing the (K-1) dummy
//   variables
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
y(:,p)=[]
 
endfunction
 
