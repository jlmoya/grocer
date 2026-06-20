function M = gmmLinJ(b,gmmopt,y,x,z)
 
// PURPOSE:  Provide Jacobian of moment conditions (Jacobian) for
//             linear GMM estimation
//-------------------------------------------------------------------------
// INPUTS:
//  . b     = model parameters
//  . gmmopt = gmm options tlist
//  . y     = "dependent" variables
//  . x     = "exogeneous" variables
//  . z     = instruments
//-------------------------------------------------------------------------
// OUPUTS:
//  . M = Jacobian  (rows(m) x k)
//-------------------------------------------------------------------------
//VERSION: 1.1.2
 
// written by:
// Mike Cliff,  Purdue Finance  mcliff@mgmt.purdue.edu
// Created: 12/10/98
// Updated: 9/26/00 (1.1.1 Does System of Eqs)
//          11//13/00 (1.1.2 No W as input argument)
// E. Michaux (2006) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
k = size(b,1);
nx = size(x,2);
neq = k/nx;
e = [];
if pmodulo(k,nx) ~= 0
  error('Problem determining number of equations');
end
 
M =eye(neq,neq).*.(-z'*x/size(x,1));
endfunction
