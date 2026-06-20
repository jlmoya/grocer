function [v]=vecr(x)
 
// PURPOSE: creates a column vector by stacking rows of x
// ------------------------------------------------------------
// INPUT:
// x = an input matrix
// ------------------------------------------------------------
// OUTPUT:
// v = output vector containing stacked rows of x
// ------------------------------------------------------------
// translated by Eric Dubois from:
// http://grocer.toolbox.free.fr/grocer.html
// James P. LeSage 2/98
// University of Toledo
// Department of Economics
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// (who thanks psummers@clyde.its.unimelb.edu.au
// for suggesting an improvement in this function)
 
[nargout,nargin] = argn(0)
if nargin~=1 then
  error('Wrong # of arguments to vecr');
end
 
xt = x';
v = xt(:);
 
endfunction
 
