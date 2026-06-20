function [yf,Bf,xf] = foremod(theta,theta2mat, z, nf, u)
 
 
// FOREMOD Forecasts the endogenous variables of an e4 model
//    [yf, Bf] = foremod(theta, din, z, k, u, userf)
// theta > parameter vector.
// din   > matrix which stores a description of the model dynamics.
// z     > matrix of observable variables.
// k     > number of forecasts.
// u     > forecasts of the exogenous variables (if any).
// yf    < (kxm) matrix of forecasts.
// Bf    < forecasts variances stored as a column of k (mxm) blocks.
//
// 7/3/97
// Copyright (c) Jaime Terceiro, 1997
 
// Number of arguments in function call
[nargout,nargin] = argn(0)
 
if nargin<4 then
   error('Incorrect number of arguments');
end;
 
[Phi,Gam,E,H,D,C,Q,S,R] = theta2ss(theta,theta2mat);
l = size(Phi,1)
n = size(z,1)
m = size(H,1)
r = size(Gam,2)
T = nf(2)-nf(1)+1
CRCt = C*R*C'
ESCt=E*S*C'
EQEt=E*Q*E'
 
if size(z,2)~=(m+r) then
   error('size of exogenous variable not conformable')
end
 
if r & (grocer_E4OPTION('econd') == 'umean' | grocer_E4OPTION('econd') == 'u0')
   if grocer_E4OPTION('econd') == 1
      u0 = mean0(z(:,m+1:m+r))';
  else
      u0 = z(1,m+1:m+r)';
  end;
  [x0,Sigm,iSigm,nonstat] = djccl(Phi,EQEt,0,Gam*u0);
  //
else
  [x0,Sigm,iSigm,nonstat] = djccl(Phi,EQEt,0,[]);
end;
 
if ~nonstat then //
   iSigm = pinv(Sigm)
end
 
Phibb0 = eye(l,l);
WW = zeros(l,l)
WZ = zeros(l,1)
V = eye(l,l)
P0 = zeros(l,l)
yf = zeros(nf(2)-nf(1)+1,m)
Bf = zeros((nf(2)-nf(1)+1)*m,m)
xf = zeros((nf(2)-nf(1)+1),l)
 
for t = 1:min(n,n+nf(1)-1); // filter loop
 //
   if r then
      z1 = z(t,1:m)' - H*x0 - D*z(t,m+1:m+r)'
   else
      z1 = z(t,1:m)' - H*x0
   end
 
   B1  = H*P0*H' + CRCt
   U = cholp(B1,grocer_E4OPTION('scale B')*abs(B1));
   iB1 = (eye(m,m)/U)/U';
 
   K1  = ((Phi*P0*H' + ESCt)/U)/U';
   Phib = Phi - K1*H
   P0  = Phib*P0*Phib' + EQEt + K1*CRCt*K1' - K1*ESCt' - ESCt*K1';
 
   if r then
      x0 = Phi*x0 + Gam*z(t,m+1:m+r)' + K1*z1
   else
      x0 = Phi*x0 + K1*z1
   end
 
    Y = H*Phibb0
    WW  = WW + Y'*iB1*Y
    WZ  = WZ + Y'*iB1*z1
    Phibb0 = Phib*Phibb0
    V = Phi*V - K1*Y
 //
end
 
if or(isnan([WW,WZ]))|or(isinf([WW,WZ])) then
   error('Initial conditions are meaningless');
end;
 
P1T = pinv(iSigm+WW)
if grocer_E4OPTION('econd') ~= 'ml' then
   x1T = P1T*WZ
else
   x1T = pinv(WW)*WZ
end
 
P0 = P0 + V*P1T*V';
x0 = x0 + V*x1T;

for t = 1:nf(2)-nf(1)+max(1,nf(1))
// forecast loop
    B1  = H*P0*H' + CRCt;
    Bf((t-1)*m+1:t*m,:) = B1;
    if r then
       yf(t,:) = (H*x0 + D*u(t,:)')';
       x0  = Phi*x0 + Gam*u(t,:)';
    else
       yf(t,:) = (H*x0)';
       x0  = Phi*x0;
    end
    xf(t,:)=x0'
    P0  = Phi*P0*Phi' + EQEt;
end
yf=yf(max(1,nf(1)):$,:)
xf=xf(max(1,nf(1)):$,:)
Bf=Bf((max(1,nf(1))-1)*m+1:$,:)

endfunction
