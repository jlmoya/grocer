function [y]=bge(jj,nq,B,cc)
 
// PURPOSE: closed form solution for integral of B(z)g(z)(1/z)^j
//  (eqn 16) in Christiano-Fitzgerald (1999) paper
//     nq > 0, jj >= 0
//     if nq = 0, y = 2*pi*B(absj+1)*cc(1);
// ------------------------------------------------------------
// INPUT:
// * jj = exponent of 1/z
// * nq = truncation lag
// * B = a (nx1) vector
// * cc =  (nx1) vector (discretisation of function g)
// ------------------------------------------------------------
// OUTPUT:
// y = the result of the integration
// ------------------------------------------------------------
// Copyright Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
// translated from Terry Fitzgerald
//   tj.fitzgerald@clev.frb.org
//
absj = abs(jj);
if absj>=nq then
  dj = B(absj+1)*cc(1)+B(absj+2:absj+nq+1)'*cc(2:nq+1);
  %v1 = B(absj-nq+1:absj)
  dj = dj+%v1($:-1:1,:)'*cc(2:nq+1);
 
elseif absj>=1 then
  dj = B(absj+1)*cc(1)+B(absj+2:absj+nq+1)'*cc(2:nq+1);
  %v1 = B(1:absj)
  dj = dj+%v1($:-1:1,:)'*cc(2:absj+1);
  dj = dj+B(2:nq-absj+1)'*cc(absj+2:nq+1);
 
else
  dj = B(absj+1)*cc(1)+2*B(2:nq+1)'*cc(2:nq+1);
 
end
 
y = 2*%pi*dj;
endfunction
