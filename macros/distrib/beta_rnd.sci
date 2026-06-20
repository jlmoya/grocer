function [rnd]=beta_rnd(n,a,b)
 
// PURPOSE: random draws from the beta(a,b) distribution
// ------------------------------------------------------------
// INPUT:
// *  n = a scalar for the size of the vector to be generated
// or n(1) = nrows, n(2) = ncols for a matrix to be generated
// * a = beta distribution parameter, a = scalar
// * b = beta distribution parameter  b = scalar
// ------------------------------------------------------------
// OUPTUT:
// t = n-vector of random draws from the beta(a,b) distribution
// ------------------------------------------------------------
// NOTE:  mean = a/(a+b), variance = ab/((a+b)*(a+b)*(a+b+1))
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
if nargin~=3 then
  error('Wrong # of arguments to beta_rnd');
end
 
if or(or(a<=0|b<=0)) then
  error('Parameter a or b is nonpositive');
end
 
if size(n) == 1 then
   n=[n;1]
end
 
a1n = gamm_rnd(n(1),n(2),a,1);
a1d = gamm_rnd(n(1),n(2),1,b,1);
rnd = a1n ./ (a1n+a1d);
 
endfunction
