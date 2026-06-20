function [pdf]=tdis_pdf(x,n)
 
// PURPOSE: returns the pdf at x of the t(n) distribution
// ------------------------------------------------------------
// INPUT:
// * x = a matrix, vector or scalar
// * n = a matrix or scalar parameter with dof
// ------------------------------------------------------------
// OUTPUT:
// a matrix of pdf at each element of x of the t(n)
// distribution
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
  error('Wrong # of arguments to tdis_pdf');
end
 
if or(n<=0) then
  error('dof in tdis_pdf is wrong');
end
 
pdf = gamma((n+1)/2) ./ sqrt(n*%pi) ./ gamma(n/2) .* ((1+x.^2/n).^(-(n+1)/2));
 
endfunction
