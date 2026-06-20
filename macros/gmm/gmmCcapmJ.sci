function G=gmmCcapmJ(b,gmmopt,Y,X,Z)
 
// PURPOSE: Gradiants of moment condition
//        for power utility CCAPM example.
//-------------------------------------------------------------------
// INPUTS:
// . b = k-vector of model parameters
// . gmmopt = gmm options tlist
// . X = (nobs x k) matrix of exogenous variables
// . Y = (nobs x neq) matrix of endogenous variables
// . Z = (nobs x nz) vector of instruments
//-------------------------------------------------------------------
// OUTPUTS
// . G = (neq x 1) vector of gradiants
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
R = X(:,2:size(X,2));
cg = X(:,1);
 
imrs = b(1)*cg.^(-b(2));
dimrs1 = cg.^(-b(2));
dimrs2 = -imrs.*log(cg);
G = [];
for i = 1:size(R,2)
  temp = [Z'*(dimrs1.*R(:,i)) Z'*(dimrs2.*R(:,i))]/T;
  G = [G; temp];
end
 
endfunction
