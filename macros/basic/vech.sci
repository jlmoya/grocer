function [v]=vech(x)
 
// PURPOSE: create a column vector by stacking columns of x
//          on and below the diagonal
//----------------------------------------------------------
// INPUT:
// x = an input matrix
//---------------------------------------------------------
// OUTPUT:
// v = output vector containing stacked columns of x
//----------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// transalted to scilab from:
// Mike Cliff, UNC Finance  mcliff@unc.edu
 
[nargout,nargin] = argn(0)
if nargin~=1 then
  error('Wrong # of arguments to vech');
end
 
v = x(tril(ones(x)) == 1)
 
endfunction
 
