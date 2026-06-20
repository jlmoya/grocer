function [M,e] = gmmMsdJ(b,igmmopt,y,x,z)
 
// PURPOSE:  Provide Jacobian and error term for Mean/StdDev GMM estimation
//-------------------------------------------------------------------------
// INPUTS:
//  . b     = model parameters
//  . gmmopt = gmm options tlist
//  . y     = dependent variable
//  . x     = exogeneous variable
//  . z     = instruments
//-------------------------------------------------------------------------
// OUPUTS:
//  . M  = Jacobian  (k+k(k+1)/2 by k+k(k+1)/2) (k is cols(y)
//  . e  = model errors  (Nobs x Neq)
//-------------------------------------------------------------------------
// VERSION: 1.2 (5/20/05)
// written by:
// Mike Cliff,  Virginia Tech Finance  mcliff@vt.edu
// Created: 6/6/00
// Updated: 5/20/05
// E. Michaux (2006) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[T,k] = size(y);
kk = k*(k+1)/2;
M = zeros(k+kk,k+kk);
M(1:k,1:k) = -eye(k,k);
M(k+1:k+kk,k+1:k+kk) = -eye(kk,kk);
e = y - repmat(b(1:k)',T,1);
ct = k;
for i = 1:k
  for j = i:k
    ct = ct + 1;
    if i == j
      M(ct,i) = -2*e(:,i)'*z/T;
    else
      M(ct,i) = -e(:,j)'*z/T;
      M(ct,j) = -e(:,i)'*z/T;
    end
  end
end
 
endfunction
