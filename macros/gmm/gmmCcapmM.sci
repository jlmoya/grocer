function [m,e]=gmmCcapmM(b,gmmopt,Y,X,Z)
 
// PURPOSE: Moments condition for power utility CCAPM example.
//-------------------------------------------------------------------
// INPUTS:
// . b = k-vector of model parameters
// . gmmopt = gmm options tlist
// . X = (nobs x k) matrix of exogenous variables
// . Y = (nobs x neq) matrix of endogenous variables
// . Z = (nobs x nz) vector of instruments
//-------------------------------------------------------------------
// OUTPUTS
// . e = (nobs x neq) matrix of conditions of interest
// . m = north-vector of orthog. cond. from stacking Z'h
//-------------------------------------------------------------------
// DESCRIPTION:
//   X = [c r], Y = [1 1], Z = [1 lag(c) lag(r)]
//   c:    nobs-vector of consumption growth
//   r:    (neq x 2) matrix of returns, [re rf] (1.1 = 10//)
//   imrs: nobs-vector of IMRSs
//   e:    (nobs x neq) IMRS*r=1
//
//   m_(t) = beta*[c_(t)/c_(t-1)]^-gamma
//--------------------------------------------------------------------
// written by:
// Mike Cliff,  Purdue Finance  mcliff@mgmt.purdue.edu
// E. Michaux (2007) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[T, neq] = size(Y);
k = size(Z,2);
north = neq*k;
R = X(:,2:size(X,2));
cg = X(:,1);
 
imrs = b(1)*cg.^(-b(2));
//imrs = b(1) + b(2)*[R(:,2)-1];
//e = (imrs*ones(1,neq)).*R - Y;
 
e = repmat(imrs,1,neq).*R - Y;
m = matrix(Z'*e/T,north,1);
 
endfunction
