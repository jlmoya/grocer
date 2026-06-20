function y = crout(x);
 
// PURPOSE: mimic Dauss function crout: computes the Crout
// decomposition of a square matrix without row pivoting,
// such that: X = LU
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) vector containing the numbers to be counted
// * v = (P x 1) vector containing breakpoints specifying the
//   ranges within which counts are to be made. The vector v
//   MUST be sorted in ascending order
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) vector, the counts of the elements of x that
//   fall into the regions:
//   x <= v[1],
//   v[1] < x <= v[2],
//        .
//        .
//        .
//   v[p-1] < x <= v[p]
// ------------------------------------------------------------
// NOTES:
// * The first category can be a missing value if you need to
// count missings directly.
// * xlso %inf or -%inf are allowed as breakpoints. The missing
// value must be the first breakpoint if it is included as a
// breakpoint and infinities must be in the proper location
// depending on their sign.
// * - %inf must be in the [2,1] element of the breakpoint
// vector if there is a missing value as a category as well,
// else it has to be in the [1,1] element.
// * If +%inf is included, it must be the last element of the
// breakpoint vector.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program
// by Martha J. Kosa
// (http://users.csc.tntech.edu/~mjkosa/)
 
[n,m]=size(x)
if n ~= m then
  error('input should be a square matrix')
end
 
L=[x(:,1) 0*x(:,2:n)]
U=[x(1,:)/L(1,1) ; 0*x(2:n,:)]
 
for j = 2:n
    for i = j:n
        L(i,j) = x(i,j) - L(i,1:j-1) * U(1:j-1,j);
    end
 
    U(j,j) = 1;
 
    for i = j+1:n
        U(j,i) = (x(j,i) - L(j,1:j-1) * U(1:j-1,i))/L(j,j);
    end
end
y=L+triu(U,1)
 
endfunction
