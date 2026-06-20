function [R,mu]=cholp(H,S)
 
// PURPOSE: Computes the perturbed Cholesky factor R for the
// symmetric matrix H, such that R'*R = H + mu*I.
// ------------------------------------------------------------
// INPUT:
// * H = a (n x n) symmetric square matrix
// * S = either a vector with length equal to n
// ------------------------------------------------------------
// OUTPUT:
// * R = a (nxn) square matrix
// * mu = a scalar
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
[n,m] = size(H);
if n ~= m then
  error('first input should be a square matrix')
end
 
if n == 0 then
   H=[]
   mu=0
else
   if nargin ~= 2 then
      S=0*H
   elseif S ~= 0 then
      if or(size(S)==1) then
         S = S(:);
      else
         S = diag(S);
      end
 
      if size(S,1) >= n then
         S = S(1:n,:);
         d = diag(1 ./ S);
         H = d*H*d';
      else
         S=0*H
      end
   end
   [R,mu]=cholp1(H,S)
end
 
endfunction
 
