function [v]=vec(x)
 
// PURPOSE: create a column vector by stacking columns of x
//----------------------------------------------------------
// INPUT:
// x = an input matrix
//---------------------------------------------------------
// OUTPUT:
// v = output vector containing stacked columns of x
//----------------------------------------------------------
// translated by Eric Dubois from:
// http://grocer.toolbox.free.fr/grocer.html
// KH (Kurt.Hornik@tuwien.ac.at) on 1995/05/08
// Copyright Dept of Probability Theory and Statistics TU Wien
 
// Modified by J.P. LeSage
 
[nargout,nargin] = argn(0)
if nargin~=1 then
  error('Wrong # of arguments to vec');
end
 
v = x(:);
 
endfunction
 
 
 
