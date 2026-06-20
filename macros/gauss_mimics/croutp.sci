function y = croutp(x)
 
// PURPOSE: mimic Gauss function croutp: computes the Crout
// decomposition of a square matrix without row pivoting, such
// that: X = LU
// ------------------------------------------------------------
// INPUT:
// * x = a (N x N) square nonsingular matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = a ((N+1) x N) matrix containing the lower (L) and
//   upper (U) matrices of the Crout decomposition of a
//   permuted x. The N+1 row of the matrix y gives the row
//   order of the y matrix.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a matlab program by:
// Adhemar Bultheel
// (http://www.cs.kuleuven.be/~adhemar.bultheel/)
 
 
[n,m] = size(x);
if n~=m then
   error('entry is not a square matrix')
end;
 
perm = 1:n;
y = x;
 
for i = 1:n
 
   y(perm(i:n),i) = y(perm(i:n),i)-y(perm(i:n),1:i-1)*y(perm(1:i-1),i);
   //   pivoting
   spilrij =  min ( find ( abs(y(perm(i:n),i)) == max(abs(y(perm(i:n),i))) ) + i-1 )
   if spilrij ~= i then
      hulp = perm(i);
      perm(i) = perm(spilrij);
      perm(spilrij) = hulp;
   end;
   //   stop if the matrix is singulier
   if y(perm(i),i)==0 then
      error("singular matrix");
   end;
   y(perm(i),i+1:n) = (y(perm(i),i+1:n)-y(perm(i),1:i-1)*y(perm(1:i-1),i+1:n))/y(perm(i),i);
end;
 
y=[y ; perm]
 
endfunction
