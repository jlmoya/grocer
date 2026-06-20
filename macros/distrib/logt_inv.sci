function [invl]=logt_inv(x)
 
// PURPOSE: inv of the logistic distribution
// ------------------------------------------------------------
// INPUT:
// x = a vector or scalar argument
// ------------------------------------------------------------
// OUTPUT:
// inv = the inverse (quantile) of the logistic distribution
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// NOTE: Written by KH (Kurt.Hornik@ci.tuwien.ac.at)
// Converted to MATLAB by JP LeSage, jpl@jpl.econ.utoledo.edu
// and to scilab by Eric Dubois
 
[nargout,nargin] = argn(0)
if nargin~=1 then
  error('Wrong # of arguments to logt_inv');
end
 
[r,c] = size(x);
s = r*c;
x = matrix(x,1,s);
invl = zeros(1,s);
 
k = matrix(find(x<0|x>1|isnan(x)),1,-1);
if or(k) then
   invl(k) = %nan*ones(1,max(size(k)))
end
 
k = matrix(find(x==0),1,-1);
if or(k) then
   invl(k) = (-%inf)*ones(1,max(size(k)))
end
 
k = matrix(find(x==1),1,-1);
if or(k) then
   invl(k) = %inf*ones(1,max(size(k)))
end
 
k = matrix(find((x>0)&(x<1)),1,-1);
if or(k) then
   invl(k) = -log(1 ./ x(k)-1)
end
 
invl = matrix(invl,r,c);
 
endfunction
