function f=lfmod_103(theta)
 
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
// * g = a (npx1) vector, the gradient of the function
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
 
end
 
 
endfunction
