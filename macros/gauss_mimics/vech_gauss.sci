function [v]=vech_gauss(x)
 
// PURPOSE: mimics gauss function vech, that a creates a
// column vector by stacking columns of x on and below the
// diagonal. Note that the conventions are not the same as
// for grocer function vech
//----------------------------------------------------------
// INPUT:
// x = an input matrix
//---------------------------------------------------------
// OUTPUT:
// v = output vector containing stacked columns of x
//----------------------------------------------------------
// Copyright Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin~=1 then
  error('Wrong # of arguments to vech');
end
 
[r,c] = size(x);
v = [];
for i = 1:c
  v = [v;x(1:i,i)];
end
 
endfunction
 
