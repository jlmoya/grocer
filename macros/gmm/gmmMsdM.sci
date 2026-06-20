function [m,e] = gmmMsdM(b,y,x,z)
 
// PURPOSE:  Provide moment conditions and error term for Mean/Covar Estimates
//-------------------------------------------------------------------------
// INPUTS:
//  . b     = model parameters : k-means, then vech(cov(y)),
//  . gmmopt = gmm options tlist
//  . y     =  "dependent" variables
//  . x     = "exogeneous" variables
//  . z     = instruments
//-------------------------------------------------------------------------
// OUPUTS:
//  . m = vector of moment conditions
//  . e = model errors  (Nobs x Neq)
//-------------------------------------------------------------------------
// VERSION: 1.1 (6/6/00)
// written by:
// Mike Cliff,  Purdue Finance  mcliff@mgmt.purdue.edu
// Created: 6/6/00
// E. Michaux (2006) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[T,k] = size(y);
e = y - repmat(b(1:k)',T,1);
ct = k;
for i = 1:k
  for j = i:k
    ct = ct + 1;
    e1 = e(:,i).*e(:,j) - b(ct);
    e = [e e1];
  end
end
m = e'*z/T;
 
endfunction
