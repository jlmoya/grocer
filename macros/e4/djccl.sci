function [x0,P0,iP0,nonstat]=djccl(Phi,EQEt,k,Gu0)
 
// PURPOSE: Computes the starting conditions for the covariance
// of the state vector proposed by De Jong & Chu-Chun-Lin
// (1994) for a state space problem, written:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    z(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// These conditions are valid for stationary or non stationary
// models.
// ------------------------------------------------------------
// INPUT:
// * Phi = the PHi matrix in the state space model above
// * EQEt = E*Q*E'
// * k = a scalar, a big number for the non stationary part
//   of matrix P0
// * Gu0 = Gam* u(0)
// ------------------------------------------------------------
// OUTPUT:
// * x0 = initial condition for state vector x(t)
// * P0 = its variance-covariance matrix
// * iP0 = inverse of P0
// * nonstat
//   = 0 if no eigenvalues has its absolute values
//   greater than 1
//   = 1 if some, but not all, eigenvalues have absolute
//   values greater than 1
//   = 2 if all eigenvalues have their absolute values greater
//   than 1
// ------------------------------------------------------------
// Copyright (c) Jaime Terceiro, 1997/
// Eric Dubois 2003 for the scilab version
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
uno = grocer_E4OPTION('tol eigv');
tolM = grocer_E4OPTION('tol djccl');
tolQ = grocer_E4OPTION('tol Q djccl');
 
x0 = zeros(size(Phi,1),1);
 
[P,Q,U1,U2,R,S] = Bkjordan(Phi,uno);
 
if (size(Q,1)*size(P,1))>0 then
  //
  nonstat = 1;
  M = lyapunov(Q,S*EQEt*S');
  P0 = U2*M*U2'+k*U1*U1';
 
  U = pinv(M,tolM);
  iP0 = S'*U*S;
 
  if ~isempty(Gu0) then
     %v2=size(Q)
     x0 = x0+U2*pinv(eye(%v2(1),%v2(2))-Q,tolQ)*S*Gu0;
  end
  //
elseif size(P,1)>0 then
  //
  nonstat = 2;
 
  P0 = k*U1;
  // U1 is the identity matrix
  iP0 = 0*P0
  //
else
  //
  nonstat = 0;
  P0 = lyapunov(Q,EQEt);
  if ~isempty(Gu0) then
    %v2=size(Q)
    x0 = pinv(eye(%v2(1),%v2(2))-Q,tolQ)*Gu0;
  end
  iP0 = [];
  //
end
 
endfunction
 
