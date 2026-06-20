function [P,Q,U1,U2,iR,iS]=Bkjordan(A,cut)
 
// PURPOSE: Computes the decomposition:
// A = [U1 U2]*diag(P,Q)*inv([U1 U2])
// where P contains the eigen values of a greater in absolute
// value than cut and Q the other ones
// ------------------------------------------------------------
// INPUT:
// * A= a (nxn) matrix
// * cut = a scalar
// ------------------------------------------------------------
// OUTPUT:
// * P = a (px1) vector that stores the eigenvalues of A
// greater or equal than cut,
// * Q = a ((n-p)x1) vector that stores the eigenvalues of A
// lower than cut,
// * U1 = a (nxp) matrix
// * U2 = a (nx(n-p)) matrix
// * iU1 = a (nxp) matrix
// * iU2 = a (nx(n-p)) matrix
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003-2007 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
 
[T,U,iU,eigen] = Bkdiag(A);
 
k1 = abs(eigen)>=cut;
k2 = ~k1;
sk1 = sum(k1);
sk2 = sum(k2);
 
if sk1 & sk2 then
  P = T(k1,k1);
  U1 = U(:,k1);
  iR = iU(k1,:);
  Q = T(k2,k2);
  U2 = U(:,k2);
  iS = iU(k2,:);
 
elseif sk2 then
  P = [];
  U1 = [];
  iR = [];
  Q = A;
  U2 = eye(A);
  iS = U2;
 
else
  Q = [];
  U2 = [];
  iS = [];
  P = A;
  U1 = eye(A);
  iR = U1;
end
 
endfunction
