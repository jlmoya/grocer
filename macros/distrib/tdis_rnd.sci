function [t]=tdis_rnd(n,df)
 
// PURPOSE: returns random draws from the t(n) distribution
// ------------------------------------------------------------
// INPUT:
// *  n = a scalar for the size of the vector to be generated
// or n(1) = nrows, n(2) = ncols for a matrix to be generated
// * df = a scalar dof parameter
// ------------------------------------------------------------
// OUPTUT:
// t = a vector of random draws from the t(n) distribution
// ------------------------------------------------------------
// NOTE:  mean=0, std=1
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to tdis_rnd');
end
 
if df<=0 then
   error('tdis_rnd dof is wrong');
end
 
if size(n) == 1 then
   n=[n;1]
end
 
z = grand(n(1),n(2),'nor',0,1);
x = chis_rnd(n,df);
t = z*sqrt(df) ./ sqrt(x);
 
endfunction
