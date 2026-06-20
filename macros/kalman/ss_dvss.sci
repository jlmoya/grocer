function [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvss(theta,theta2mat,i)
 
// SS_DVSS  - Computes the partial derivatives of the matrices of the SS
// representation with respect to the i-th parameter in THETA.
//    [dPhi, dGam, dE, dH, dD, dC, dQ, dS, dR] = ss_dvss(theta, din, i)
// This function only works with native SS models.
 
[Phi,Gam,E,H,D,C,Q,S,R]=theta2ssss(theta,theta2mat,'unf')
theta(i)=theta(i)+1
[Phin,Gamn,En,Hn,Dn,Cn,Qn,Sn,Rn]=theta2ssss(theta,theta2mat,'unf')

dPhi=Phin-Phi
dGam=Gamn-Gam
dE=En-E
dH=Hn-H
dD=Dn-D
dC=Cn-C
dQ=Qn-Q
dS=Sn-S
dR=Rn-R

p=size(Phi,1)
m=size(H,1)
if isempty(dE) then
   dE=zeros(p,p)
end 
if isempty(dC) then
   dC=zeros(m,m)
end 
if isempty(dR) then
   R=zeros(m,m)
   dR=zeros(m,m)
end 
if isempty(dQ) then
   Q=zeros(p,p)
   dQ=zeros(p,p)
end 
if isempty(dS) then
   dS=zeros(size(dQ,1),size(dR,1))
end 

if isempty(Gam) then
   Gam=zeros(p,max(grocer_e4param.r,1))
   dGam=zeros(p,max(grocer_e4param.r,1))
end 
if isempty(D) then
   D=zeros(m,max(grocer_e4param.r,1))
   dD=zeros(m,max(grocer_e4param.r,1))
end 

if grocer_E4OPTION('var') == 'factorized' then
   dQ = Q*dQ'+dQ*Q';
   dR = R*dR'+dR*R';
end
 
endfunction
