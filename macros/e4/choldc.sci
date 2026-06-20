function [L,maxadd]=choldc(H,maxoffl)
 
// PURPOSE: Computes the perturbed Cholesky decomposition
//  LL'=H+D.
// D is a diagonal non-negative matrix which is computed when
// it isnecessary to grant that:
// a) the elements in the diagonal of L are greater than a
// tolerance and
// b) that the elements in the lower triangle are less that
// maxoffl
// ------------------------------------------------------------
// INPUT:
// * H = a (nxn) symmetric square matrix
// * maxoffl = a scalar, equal to the max value authorized for
// the -perturbed- Choleski decomposition
// ------------------------------------------------------------
// OUTPUT:
// * L = a (nxn) square matrix
// * maxadd = the bigger element of D.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
// Based on CHOLDECOMP. Dennis & Schnabel (1983), pp. 315
 
n = size(H,1);
minl = sqrt(sqrt(%eps))*maxoffl;
if maxoffl==0 then
  maxoffl = sqrt(max(abs(diag(H))));
end
minl2 = sqrt(%eps)*maxoffl;
maxadd = 0;
L = zeros(n,n);
 
if n > 1 then
  L(1,1) = H(1,1);
  minljj = 0;
  L(2:n,1) = H(1,2:n)';
  minljj = max(max(abs(L(2:n,1))),minljj);
  minljj = max(minljj/maxoffl,minl);
  if L(1,1)>(minljj^2) then
    L(1,1) = sqrt(L(1,1));
  else
    minljj = max(minljj,minl2);
    maxadd = max(maxadd,minljj^2-L(1,1));
    L(1,1) = minljj;
  end
  L(2:n,1) = L(2:n,1)/L(1,1);
end
 
for j = 2:n-1
  L(j,j) = H(j,j)-sum(L(j,1:j-1).^2);
  minljj = 0;
  L(j+1:n,j) = H(j,j+1:n)'-L(j+1:n,1:j-1)*L(j,1:j-1)';
  minljj = max(max(abs(L(j+1:n,j))),minljj);
  minljj = max(minljj/maxoffl,minl);
  if L(j,j)>(minljj^2) then
    L(j,j) = sqrt(L(j,j));
  else
    minljj = max(minljj,minl2);
    maxadd = max(maxadd,minljj^2-L(j,j));
    L(j,j) = minljj;
  end
  L(j+1:n,j) = L(j+1:n,j)/L(j,j);
end
 
L(n,n) = H(n,n)-sum(L(n,1:n-1).^2);
if L(n,n)>(minl^2) then
  L(n,n) = sqrt(L(n,n));
else
  minl = max(minl,minl2);
  maxadd = max(maxadd,minl^2-L(n,n));
  L(n,n) = minl;
end
 
endfunction
 
