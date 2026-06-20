function B = dnplus(n)
 
// PURPOSE : Let W be a (k x k) covariance matrix and let
// vec(W) be the (k*k x 1) vector obtained by stacking the
// columns of W. Additionally, let vech(W) be the vector
//  obtained vertically stacking those elements on or below
// the principal diagonal of W.
//
// Define Dn the duplication matrix, that is the unique
// matrix satisfying
//              Dn * vech(W) = vec(W)
//
// Define Dnp = inv(Dn' * Dn) * Dn' so that
//
//              vech(W) = Dnp * vec(W)
//
// The function dnplus computes Dnp for the case k = n
//----------------------------------------------------------
// INPUT:
// n = a scalar, equal to the size of the symmetric matrix
//------------------------------------------------------------
// OUTPUT:
// B =  a ( (n*(n+1)/2) x (n*(n+1)/2)) matrix
//----------------------------------------------------------
// Copyright Julien Matheron, Tristan Maury, UPX MODEM,
// July 2002
// E. Michaux (2005) for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
m = n*(n+1)/2
A = eye(m,m)
B = zeros(m,n^2)
for ii = 1:n
   B(:,(ii-1)*n+ii:ii*n)=A(:,1:n-(ii-1))
   A = A(:,n-(ii-1)+1:$)
end
 
endfunction
 
