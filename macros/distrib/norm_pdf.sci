function [pdf]=norm_pdf(x,m,v)
 
// PURPOSE: computes the normal probability density function
//          for each component of x with mean m, variance v
// ------------------------------------------------------------
// INPUT:
// * x = variable matrix (n x p)
// * m = a scalar or a matrix with the same dimensions as x
// (default=0)
// * v = a scalar or a matrix with the same dimensions as x
// (default=1)
// ------------------------------------------------------------
// OUTPUT:
// pdf == (nxm) vector containing pdf for each x
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Written by TT (Teresa.Twaroch@ci.tuwien.ac.at)
// Updated by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by James P. Lesage,
// jpl@jpl.econ.utoledo.edu
// and adapted to scilab by Eric Dubois
 
 
[nargout,nargin] = argn(0)
if ~(nargin==1|nargin==3) then
  error('Wrong # of arguments to norm_pdf')
end
 
[r,c] = size(x)
 
if nargin==1 then
  m = zeros(r,c)
  v = ones(r,c)
end
 
// modification proposed by S. Mottelet to deal with matrices
pdf = stdn_pdf((x-m) ./ sqrt(v)) ./ sqrt(v)
 
 
endfunction
