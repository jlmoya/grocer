function [m,e] = gmmLinM(b,gmmopt,y,x,z)
 
// PURPOSE:  Provide moment conditions and error term for
//             linear GMM estimation
//-------------------------------------------------------------------------
// INPUTS:
//  . b     = model parameters
//  . gmmopt = gmm options tlist
//  . y     = dependent variable
//  . x     = exogeneous variable
//  . z     = instruments
//-------------------------------------------------------------------------
// OUTPUS:
//  . m = vector of moment conditions
//  . e = model errors  (Nobs x Neq)
//-------------------------------------------------------------------------
// VERSION: 1.1.2
// written by:
// Mike Cliff,  Purdue Finance  mcliff@mgmt.purdue.edu
// Created: 12/10/98
// Modified 9/26/00 (1.1.1 Does system of Eqs)
//          11//13/00 (1.1.2 No W as input argument)
// E. Michaux (2006) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
k = size(b,1);
nx = size(x,2);
neq = k/nx;
e = [];
if pmodulo(k,nx) ~= 0
  error('Problem determining number of equations')
end
 
for i = 1:neq
  ei = y(:,i) - x*b((i-1)*nx+1:i*nx);
  e = [e ei];
end
 
m = vec(z'*e/size(e,1));
 
endfunction
 
