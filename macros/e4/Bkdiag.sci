function [T,U,iU,eigen]=Bkdiag(A)
 
// PURPOSE: Computes the decomposition A = U*T*inv(U)
// ------------------------------------------------------------
// INPUT:
// * A = a (nxn) matrix
// ------------------------------------------------------------
// OUTPUT:
// * T is a block diagonal matrix
// * U = a (nxn) matrix
// * iU = inv(U)
// * eigen = a (nx1) vector of A eigenvalues
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[T,U]=bdiag(A);
iU=inv(U)
l=spec(A)
[ign,idx] = gsort(-real(l),'g','i');
U = U(:,idx);
T = T(idx,idx);
iU = iU(idx,:);
eigen = l(idx);
endfunction
