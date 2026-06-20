function [cdf]=logt_cdf(x)
 
// PURPOSE: cdf of the logistic distribution
// ------------------------------------------------------------
// INPUT: x = a vector or scalar argument
// ------------------------------------------------------------
// OUTPUT:
// cdf = the cdf of the logistic distribution
// ------------------------------------------------------------
// COPYRIGHT: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by JP LeSage,
// jpl@jpl.econ.utoledo.edu
// and t scilab by Eric Dubois
 
[nargout,nargin] = argn(0)
if nargin~=1 then
  error('Wrong # of arguments to logt_cdf');
end
 
cdf = 1 ./ (1+exp(-x));
 
endfunction
