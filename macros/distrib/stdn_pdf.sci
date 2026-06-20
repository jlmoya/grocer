function [pdf]=stdn_pdf(x)
 
// PURPOSE: computes the standard normal probability density
//          for each component of x with mean=0, variance=1
// ------------------------------------------------------------
// references :
// ------------------------------------------------------------
// INPUT:
// x = variable matrix (nxm)
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
if nargin~=1 then
  error('Wrong # of arguments to stdn_pdf');
end
 
[r,c] = size(x);
s = r*c;
x = matrix(x,1,s);
pdf = zeros(1,s);
 
k = matrix(find(isnan(x)),1,-1);
if or(k) then
  pdf(k) = %nan*ones(1,max(size(k)))
end
 
k = matrix(find(~isinf(x)),1,-1);
if or(k) then
  pdf(k) = (2*%pi)^(-1/2)*exp(-x(k).^2/2)
end
 
pdf = matrix(pdf,r,c);
endfunction
