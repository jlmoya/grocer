function [ret,x,aout,bout]=com_size(x,a,b)
 
// PURPOSE: make a,b scalars equal to constant matrices of size(x)
// or leaves them unchanged if they are already common_size
// ------------------------------------------------------------
// INPUT:
// * x = a matrix or vector
// * a = a scalar or matrix
// * b = a scalar or matrix
// ------------------------------------------------------------
// OUPTUT:
// * ret = an indicator 0 if common_size, 1 if not
// * x   = input matrix
// * a   = matrix size(x) or input matrix a if already size(x)
// * b   = matrix size(x) or input matrix b if already size(x)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
if nargin~=3 then
  error('Wrong # of arguments to com_size');
end
 
[n,k] = size(x);
 
ret = 0;
 
[na,ka] = size(a);
[nb,kb] = size(b);
 
if (na==1)&(ka==1) then
  aout = ones(n,k)*a;
else
  if na~=n|ka~=k then
    ret = 1;
  end
  aout = a;
end
 
if (nb==1)&(kb==1) then
  bout = ones(n,k)*b;
else
  if nb~=n|kb~=k then
    ret = 1;
  end
  bout = b;
end
 
endfunction
 
 
 
 
 
 
