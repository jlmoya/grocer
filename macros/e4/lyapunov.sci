function [P,nonstat]=lyapunov(Phi,Q,one)
 
// PURPOSE: Checks if Phi has eigenvalue greater than or equal
// to 'one' and if this is not the case, then Solves the
// Lyapunov equation P = Phi*P*Phi' + Q
// ------------------------------------------------------------
// INPUT:
// * Phi = a (nxn) matrix
// * Q = a matrix withe teh same size
// * one= a scalar
// ------------------------------------------------------------
// OUTPUT:
// * P = a (nxn) matrix
// * nonstat
//   = 0 if no eigenvalues has its absolute values
//   greater than 1
//   = 1 if some, but not all, eigenvalues have absolute
//   values greater than 1
//   = 2 if all eigenvalues have their absolute values greater
//   than 1
// ------------------------------------------------------------
// NOTE: Convention used here is not the same as in Scilab:
// sign of Q must be changed to conform to scialb convention
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin<3 then
  one = grocer_E4OPTION('tol eigv');
end
 
n = size(Phi,1);
nuroots = size(matrix(find(abs(spec(Phi))>=one),1,-1),1);
P=zeros(n,n)
 
if nuroots == 0 then
  nonstat = 0;
  P=lyap(real(Phi'),-real(Q),'d')
elseif nuroots==n then
   nonstat = 2;
else
   nonstat = 1;
end
 
endfunction
