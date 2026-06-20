function [f,g,ind]=lfmod_gmod_103(theta,ind)
 
// PURPOSE: Computes the exact likelihood function of a general
// State Space model.
// 103 means:
// - the use of the kalman filter (1)
// - the first value of the exogenous variable for the initial
// conditions (econd=3)
// - the estimate of initial values is not made (MV=0)
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of intial values for the parameters
// * ind = a flag for optim (see optim for details)
// ------------------------------------------------------------
// OUTPUT:
// * f = a scalar, the function value (minus loglikelihood)
// * g = a (np x 1) vector, the gradient of the function
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation and adaptation
// http://grocer.toolbox.free.fr/grocer.html
 
param=grocer_e4param
m=param.m
T=grocer_e4_T
 
[Phi,Gam,E,H,D,C,Q,S,R] = theta2ss(theta,grocer_e4_theta2mat);
y=grocer_e4_z(:,1:m)
r = size(grocer_e4_z,2)-m;
z=grocer_e4_z(:,m+1:m+r)
 
[x00,P00] = lfmodini(Phi,Gam,E,H,D,C,Q,S,R,grocer_e4_z,grocer_e4_MV);
nx=size(x00,1)
 
// the 25 following lines of code have been added to make
// the program run with Scilab versions from the 6.0 one
if r ==0 then
   z=zeros(T,1)
end
if isempty(E) then
   E=zeros(nx,nx)
end
if isempty(C) then
   C=zeros(m,m)
end
if isempty(R) then
   R=zeros(m,m)
end
if isempty(Q) then
   Q=zeros(nx,nx)
end
if isempty(S) then
   S=zeros(size(Q,1),size(R,1))
end
 
if isempty(Gam) then
   Gam=zeros(nx,max(r,1))
end
if isempty(D) then
   D=zeros(m,max(r,1))
end
 
CRCt = C*R*C';
ESCt = E*S*C';
EQEt = E*Q*E';
 
f = .5*T*m*log(2*%pi)
np = param.np
g = zeros(np,1);
 
x0= x00;
P0 = P00;
 
z1=zeros(m,T)
B1_3d=zeros(m,m*T)
iB1_3d=zeros(m,m*T)
x0_3d=ones(1,T+1).*.x0
P0_3d=ones(1,T+1).*.P0
K1_3d=zeros(nx,m*T)
 
Gamz=Gam*z'
Dz=D*z'
 
for t = 1:T
   z1(:,t) = y(t,:)'-H*x0-Dz(:,t);
   B1 = H*P0*H'+CRCt;
 
   U = cholp1(B1,grocer_E4OPTION('scale B')*abs(B1));
   iU=U\eye(m,m)
   iB1 = iU*iU';
   K1 = (Phi*P0*H'+ESCt)*iB1;
 
   x0 = Phi*x0+Gamz(:,t)+K1*z1(:,t);
   Phib = Phi-K1*H;
   P0 = Phib*P0*Phib'+EQEt+K1*CRCt*K1'-K1*ESCt'-ESCt*K1';
    //
   z1U = z1(:,t)'*iU;
 
   f = f+sum(log(diag(U)))+0.5*trace(z1U*z1U');
 
   K1_3d(:,m*(t-1)+1:m*t)=K1
   B1_3d(:,m*(t-1)+1:m*t)=B1
   iB1_3d(:,m*(t-1)+1:m*t) = iB1
 
   x0_3d(:,t+1)=x0
   P0_3d(:,nx*t+1:nx*(t+1))=P0
  //
end
// t
 
for i = 1:np
  //
   [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dv(theta,grocer_e4_theta2mat,i);
   dx0 = zeros(nx,1);
   dP0 = zeros(nx,nx);
   [P0,nonstat] = lyapunov(Phi,E*Q*E');
 
   if nonstat>0 then
      if or(dPhi)|or(dE)|or(dQ)|or(dGam) then
          k = 0;
          // numerical difference step
          [x0,P0] = djccl(Phi,E*Q*E',k,Gam*grocer_e4_u0);
          [x1,P1] = djccl(Phi+dPhi*grocer_e4_deps,(E+dE*grocer_e4_deps)*(Q+dQ*grocer_e4_deps)...
          *((E+dE*grocer_e4_deps)'),k,(Gam+dGam*grocer_e4_deps)*grocer_e4_u0);
          dx0 = (x1-x0)/grocer_e4_deps;
          dP0 = (P1-P0)/grocer_e4_deps;
      end
   else
      dPhib = dPhi*P0*Phi';
      dQb = dE*Q*E';
      dP0 = lyapunov(Phi,dPhib+dPhib'+dQb+E*dQ*E'+dQb');
   end
 
   gg = 0;
   dB1_0 = dC*R*C'+C*dR*C'+C*R*dC'
   dK1_0 = dE*S*C'+E*dS*C'+E*S*dC'
   dP1_0 = dE*Q*E'+E*dQ*E'+E*Q*dE'
 
   for t = 1:T
      P0=P0_3d(:,nx*(t-1)+1:nx*t)
      x0=x0_3d(:,t)
      B1=B1_3d(:,m*(t-1)+1:m*t)
      iB1=iB1_3d(:,m*(t-1)+1:m*t)
      K1=K1_3d(:,m*(t-1)+1:m*t)
      Phib = Phi-K1*H;
 
      dz1 = -dH*x0-H*dx0-dD*z(t,:)';
      HP0=H*P0
      dB1 = dH*HP0'+H*dP0*H'+HP0*dH'+dB1_0
 
      dK1 = (dPhi*HP0'+Phi*dP0*H'+Phi*P0*dH'+dK1_0-K1*dB1)*iB1;
      dPhib = dPhi-dK1*H-K1*dH;
 
      dGamb = dGam-dK1*D-K1*dD;
      dx0 = dPhib*x0+Phib*dx0+dGamb*z(t,:)'+dK1*y(t,:)';
      PhibP0=Phib*P0
      K1CRCt=K1*CRCt
      dP0 = dPhib*PhibP0'+Phib*dP0*Phib'+PhibP0*dPhib'+dP1_0+...
      dK1*K1CRCt'+K1*dB1_0*K1'+K1CRCt*dK1'-dK1*ESCt'-K1*dK1_0'-...
      dK1_0*K1'-ESCt*dK1';
      z1i = z1(:,t)'*iB1;
 
      gg = gg+.5*trace(iB1*dB1)+z1i*dz1-.5*(z1i*dB1*z1i');
   //
   end
   g(i) = gg;
   //
end
 
endfunction
