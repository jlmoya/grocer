function [x0,Ao,Bo,Co,Do,P0,iP0,nonstat]=lfmodini(Phi,Gam,E,H,D,C,Q,S,R,z,MV,KF)
 
// PURPOSE: Computes initial conditions for lfmod and
// lfmod_gmod_103 in a model witten in an SS form:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    z(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// ------------------------------------------------------------
// INPUT:
// * Phi, Gam, E, H, D, C, Q, S, R, z = the matrices of the SS
//   form
// * MV=1 if the ML estimation of x0 will be done during
//   the likelihood function evaluation.
// * KF=1 use Kalman filter only.
// ------------------------------------------------------------
// OUTPUT:
// * x0 = the initial state (px1) vector.
// * Ao =    <   P0         B0
// * Bo      <   []         K0
// * Co      <   []         y0
// * Do      <   []         M0
// * P0 = covariance of the initial state vector.
// * iP0 = inverse of P0 (can be rank-defficient if P0 ->INF).
// * nonstat = 0 if the system is stationary,
//           = 1 if the system is partially nonstationary
//           = 2 if the system is nonstationary.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
if nargin<12 then
  KF = 0;
end
if nargin<11 then
  MV = 0;
end
grocer_e4_econd=grocer_E4OPTION('econd')
grocer_e4_vcond=grocer_E4OPTION('vcond')
grocer_e4_scaleb=grocer_E4OPTION('scale B')
exo_init=(r&(grocer_e4_econd=='umean'|grocer_e4_econd=='u0'))
grocer_e4_filtk=(grocer_E4OPTION('filter') == 'kalm')
 
n = size(z,1);
l = size(Phi,1);
m = size(H,1);
r = size(Gam,2);
 
x0 = zeros(l,1);
P0 = zeros(l,l);
 
if (grocer_e4_econd=='ml')&(grocer_e4_MV==0) then
  // Maximum likelihood estimator of the initial state vector
  //
  Phibb0 = eye(l,l);
  x0s = x0;
  CRCt = C*R*C';
  ESCt = E*S*C';
  EQEt = E*Q*E';
  WW = zeros(l,l);
  WZ = zeros(l,1);
 
  for t = 1:n
    //
    B1 = H*P0*H'+CRCt;
    if grocer_e4_scaleb then
      U = cholp(B1,abs(B1));
    else
      U = cholp(B1);
    end
    %v2=size(U)
    iB1 = eye(%v2(1),%v2(2))/U/U';
    K1 = (Phi*P0*H'+ESCt)*iB1;
 
    if r then
      z1s = z(t,1:m)'-D*z(t,m+1:m+r)'-H*x0s;
      x0s = Phi*x0s+Gam*z(t,m+1:m+r)'+K1*z1s;
    else
      z1s = z(t,1:m)'-H*x0s;
      x0s = Phi*x0s+K1*z1s;
    end
 
    Phib = Phi-K1*H;
    P0 = Phib*P0*Phib'+EQEt+K1*CRCt*K1'-K1*ESCt'-ESCt*K1';
    HPhi = H*Phibb0;
    WW = WW+HPhi'*iB1*HPhi;
    WZ = WZ+HPhi'*iB1*z1s;
    Phibb0 = Phib*Phibb0;
    //
  end
  // t
 
  if or(isnan([WW,WZ]),1)|or(isinf([WW,WZ]),1) then
    error('Initial conditions are meaningless');
  end
  x0 = pinv(WW,grocer_e4_zeps)*WZ;
  P0 = zeros(l,l);
  //
end
 
if grocer_e4_vcond =='lyap' then
  //
  [P0,nonstat] = lyapunov(Phi,E*Q*E');
 
  if nonstat>0 then
    // non stationary
    //
    if ~grocer_e4_filtk then
       error('Non-stationary system. Initial conditions not compatible with Chandrasekhar')
    end
 
    grocer_e4_vcond = 'djong';
    // Change of initial conditions
    //
  elseif exo_init then
    x0 = pinv(eye(l,l)-Phi,grocer_e4_zeps)*Gam*grocer_e4_u0';
  end
  //
end
 
if grocer_e4_vcond == 'djong' | grocer_e4_vcond == 'idjong'
   k = grocer_E4OPTION('dejong k')*(grocer_e4_vcond == 'djong')
 
   if exo_init then
     [x0,P0,iP0,nonstat] = djccl(Phi,E*Q*E',k,Gam*grocer_e4_u0');
   else
     [ignore,P0,iP0,nonstat] = djccl(Phi,E*Q*E',k,[]);
   end
  //
else
  iP0 = [];
end
 
if grocer_e4_filtk then
  Ao = P0;
  Bo = [];
  Co = [];
  Do = [];
else
  //
  if grocer_e4_vcond=='lyap' then
    B0 = H*P0*H'+C*R*C';
    if grocer_e4_scaleb then
      U = cholp(B0,abs(B0));
    else
      U = cholp(B0);
    end
    %v2=size(B0)
    iB0 = eye(%v2(1),%v2(2))/U/U';
    y0 = Phi*P0*H'+E*S*C';
    K0 = y0*iB0;
    M0 = -iB0;
  else
    B0 = C*R*C';
    if scaleb then
      U = cholp(B0,abs(B0));
    else
      U = cholp(B0);
    end
    %v2=size(B0)
    iB0 = eye(%v2(1),%v2(2))/U/U';
    y0 = E;
    K0 = E*S*C'*iB0;
    M0 = Q-S*C'*inv(C*R*C')*C*S';
  end
  Ao = B0;
  Bo = K0;
  Co = y0;
  Do = M0;
end
 
endfunction
