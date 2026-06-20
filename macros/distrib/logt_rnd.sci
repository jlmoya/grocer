function [rnd]=logt_rnd(r,c)
 
// PURPOSE: random draws from the logistic distribution
// ------------------------------------------------------------
// INPUT:
// r,c = size of the matrix, vector or scalar of draws
// ------------------------------------------------------------
// OUPTUT:
// rnd = a matrix of random numbers from the logistic
// distribution
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// NOTE: Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by JP LeSage, jpl@jpl.econ.utoledo.edu
// and to scilab by Eric Dubois
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to logt_rnd');
end
 
if ~((is_scalar(r)&(r>0))&(r==round(r))) then
  error('logt_rnd:  r must be a positive integer');
end
 
if ~((is_scalar(c)&(c>0))&(c==round(c))) then
  error('logt_rnd:  c must be a positive integer');
end
 
rnd = -log(ones(r,c) ./ grand(r,c,'def')-ones(r,c));
 
endfunction
