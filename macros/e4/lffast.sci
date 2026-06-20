function f=lffast(theta,theta2mat,z,u0)
 
// PURPOSE: Fast evaluation of the exact likelihood function
// for any time-invariant SS model (in that case lffast outputs
// the same result that lfmod with vcond = 'idej'. It is valid
// for stationary and/or nonstationary models.
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * z = matrix of endogenous and exogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * f = function value
// * z1 = vector of measure innovations
// * x0 = state vector
// ------------------------------------------------------------
// Copyright (c) Jaime Terceiro, 1997
// Eric Dubois 2003 for the scilab tanslation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
[Phi,Gam,E,H,D,C,Q,S,R] = grocer_theta2ss(theta,theta2mat);
 
n = size(z,1);
l = size(Phi,1);
r = max([size(Gam,2),size(D,2)]);
m = size(H,1)
 
if ~grocer_e4_innov(1) then
  //
  [E,Q,U,iU] = sstoinn(Phi,E,H,C,Q,S,R);
  //
else
  //
  Q = C*Q*C';
  E = E*pinv(C);
 
  U = cholp1(Q,grocer_E4OPTION('scale B')*abs(Q));
  iU = eye(m,m)/U';
end
 
[x0,Sigm,iSigm,nonstat] = djccl(Phi,E*Q*E',0,Gam*u0);
 
x00=x0
WW = zeros(l,l);
WZ = zeros(l,1);
Phib = Phi-E*H;
Phibb0 = iU*H;
 
N= eye(l,l);
ff = 0;
 
z1 = zeros(m,n);
 
if r then
   for t = 1:n
   // main loop
      z1(:,t) = z(t,1:m)'-H*x0-D*z(t,m+1:m+r)';
      x0 = Phi*x0+Gam*z(t,m+1:m+r)'+E*z1(:,t);
      WW = WW+Phibb0'*Phibb0;
      WZ = WZ+Phibb0'*iU*z1(:,t);
      Phibb0 = Phibb0*Phib;
   //
   end
else
   for t = 1:n
      z1(:,t) = z(t,:)'-H*x0;
      x0 = Phi*x0+E*z1(:,t);
      WW = WW+Phibb0'*Phibb0;
      WZ = WZ+Phibb0'*iU*z1(:,t);
      Phibb0 = Phibb0*Phib;
   end
end
 
ff = 2*n*sum(log(diag(U)))+sum((iU*z1).^2);
 
if or(isnan([WW,WZ]),1)|or(isinf([WW,WZ]),1) then
   warning('Initial conditions has become meaningless');
   write(%io(2),'trying to overcome this problem','(a)')
   f=1E8+grand(1,1,'nor',0,1)
end
 
 
if ~nonstat then
  // stationary system
  //
  [Ns,S,Ns] = svd(Sigm);
  k =find(diag(S)<grocer_e4_zeps)
  if size(k,2)<l then
    if size(k,2) then
      //
      N = Ns(:,1:k(1)-1);
      Sigm = S(1:k(1)-1,1:k(1)-1);
      WW = N'*WW*N;
      WZ = N'*WZ;
      //
    end
    M = cholp(Sigm);
    T = cholp(eye(size(M,1),size(M,1))+M*WW*M');
    ff = ff+2*sum(log(diag(T)));
    if grocer_E4OPTION('econd')=='ml' then
      T = cholp(WW);
      ff = ff-sum((T'\WZ).^2);
    else
      ff = ff-sum((T'\(M*WZ)).^2);
    end
 
  end
  //
elseif nonstat==2 then
  // non stationary system
  //
  T = cholp(WW);
  ff = ff+2*sum(log(diag(T)))-sum((T'\WZ).^2);
  //
else
  // partially stationary
  //
  S = svd(Sigm);
  T = cholp(iSigm+WW);
  ff = ff+2*sum(log(diag(T)))+sum(log(S(S>grocer_e4_zeps)));
  if grocer_E4OPTION('econd') == 'ml' then
    T = cholp(WW);
  end
  ff = ff-sum((T'\WZ).^2);
  //
end
 
f = .5*(ff+n*m*log(2*%pi));
 
endfunction
 
