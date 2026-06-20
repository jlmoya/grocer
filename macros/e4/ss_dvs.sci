function [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR]=ss_dvs(theta,theta2mat,i)
 
// PURPOSE: Computes the partial derivatives of the matrices of
// a SS model with respect to the i-th parameter in theta.
// The model is suppose to be written as follows:
//    x(t+1) = Phi�x(t) + Gam�u(t) + E�w(t)
//    y(t)   = H�x(t)   + D�u(t)   + C�v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * i = a scalar
// ------------------------------------------------------------
// OUTPUT:
// dPhi, dGam, dE, dH,dD,dC,dQ,dS,dR = the derivatives of the
// corresponding matrices (that is unprefixed by d) with
// respect to the i-th parameter in theta.
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation and adaptation
// http://grocer.toolbox.free.fr/grocer.html
 
m=grocer_e4param.m
r=grocer_e4param.r
k=grocer_e4param.k
[F,dF,A,dA,V,dV,G,dG] = fr_dv(theta,theta2mat,i);
 
dQ = dV;
dS = dQ;
dR = dQ;
if grocer_e4param.typ == 0|grocer_e4param.n==0 then
  dPhi = 0;
  dE = zeros(1,m);
  dH = zeros(m,1);
  dC = dA;
  dGam = zeros(1,r);
  dD=dG
return
 
end
 
F0 = F(1:m,1:m);
dF0 = dF(1:m,1:m);
A0 = A(1:m,1:m);
dA0 = dA(1:m,1:m);
 
Fb = zeros(m*k,m)
dFb = Fb
dAb = Fb
for i = 1:k
   k1=m*i+1:m*i+m
   k2=k1-m
   Fb(k2,:)=F(1:m,k1)
   dFb(k2,:)=dF(1:m,k1)
   dAb(k2,:)=dA(1:m,k1)
end
 
if r then
   G0 = G(1:m,1:r);
   dG0 = dG(1:m,1:r);
   dGb = [];
   for i = 1:k
      dGb = [dGb;dG(1:m,r*i+1:r*i+r)];
   end
   dGam = dGb-dFb*G0-Fb*dG0;
   dD = dG0;
   if isempty(dD) then
      dD=zeros(m,r)
   end
   if isempty(dGam) then
      dGam=zeros(k,r)
   end
else
   dGam=zeros(k,r)
   dD=zeros(m,r)
end
 
dPhi = [-dFb,zeros(m*k,m*(k-1))];
dE = dAb-dFb*A0-Fb*dA0;
dH = [zeros(m,m),zeros(m,m*(k-1))];
dC = dA0;
 
if isempty(dC) then
   dC=zeros(m,m)
end
if isempty(dE) then
   dE=zeros(k,k)
end
if isempty(dR) then
   dR=zeros(m,m)
end
if isempty(dQ) then
   dQ=zeros(k,k)
end
if isempty(dS) then
   dS=zeros(size(Q,1),size(R,1))
end
 
endfunction
