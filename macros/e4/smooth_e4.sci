function [x_T,P_T,z_T]=smooth_e4(theta,theta2mat,x,u0)
 
// PURPOSE: calculation of smoothed state and measure vectors
// in a time-invariant model
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * z = matrix of endogenous and exogenous variables
// * u0 = starting value of the exogenous variable
// ------------------------------------------------------------
// OUTPUT:
// * x_T = smoothed state
// * P_T = smoothed variance of the state
// * z_T = smoothed adjusted endogenous variable
// ------------------------------------------------------------
// NOTE: the function used the algorithm described in:
// Casals J., Jerez M. and Sotoca S. (2000): "Exact Smoothing
// for Stationary and Nonstationary Time Series", International
// Journal of Forecasting, vvol. 16, pp. 59-69
// ------------------------------------------------------------
// Copyright Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
[Phi,Gam,E,H,D,C,Q,S,R] = theta2ss(theta,theta2mat);
 
CRCt=C*R*C'
EQEt=E*Q*E'
n=size(x,1)
l = size(Phi,1);
r = max([size(Gam,2),size(D,2)]);
m = size(H,1)
y=x(:,1:m)
z=x(:,m+1:m+r)
r = size(x,2)-m;
// the 15 following lines of code have been added to make
// the program run with Scilab versions from the 6.0 one
if r == 0 then
   z=zeros(n,1)
end
if isempty(D) then
   D=zeros(m,1)
end
if isempty(CRCt) then
   CRCt=zeros(m,m)
end
if isempty(EQEt) then
   EQEt=zeros(m,m)
end
 
if ~isempty(R) & ~isempty(S) then
   if sum(abs(R)) ~= 0 & sum(abs(S)) ~= 0 then
      // transform the problem to obtain S=0 and be able to use
      // Scilab function ricatti
      // note: this case is not dealt for the moment since
      // no program in grocer 1.3 needs it
      // it si left to grocer future version
   end
else
// calculate the solution of the Riccati equation
   pbar=-.01*eye(l,l);
   dd=1;
   it=1;
   maxit=1000;
 
   while (dd>1e-10 & it<=maxit);
      f0=(H*pbar*H'+CRCt)\(H*pbar*Phi');
      p1=Phi*pbar*Phi' + EQEt -(Phi*pbar*H')*f0;
      f1=   (H*p1*H'+CRCt)\(H*p1*Phi');
      dd=max(abs(f1-f0))
      it=it+1;
      pbar=p1;
 
  end
 
end
 
bbar=H*pbar*H'+CRCt
kbar=Phi*pbar*H'*inv(bbar)
 
[x0,Ao,Bo,Co,Do,Sigm,iSigm,nonstat]=lfmodini(Phi,Gam,E,H,D,C,Q,S,R,grocer_e4_z,grocer_e4_MV);
//[x0,Sigm,iSigm,nonstat] = djccl(Phi,E*Q*E',0,Gam*u0);
 
dim=size(x0,1)
WW = zeros(l,l);
WZ = zeros(l,1);
Phib0 = Phi-kbar*H
ibbar=inv(cholp(bbar))
Phib = ones(n+1,1) .*. eye(dim,dim);
Hp_ibbar=H'*ibbar'*ibbar
Phibb0 = ibbar*H
x_t=zeros(n+1,dim)
x_t(1,:)=x0'
Phib0_3d=[Phib0 zeros(l,l*n)]
 
N= eye(l,l);
 
z1 = zeros(m,n);
 
// propagate forward a KF(0,Pbar)
if r then
   if isempty(D) then
       D=zeros(m,r)
   end
   if isempty(Gam) then
       Gam=zeros(dim,r)
   end
   for t = 1:n
      z1(:,t) = y(t,:)'-H*x_t(t,:)'-D*z(t,:)';
      x_t(t+1,:) = (Phi*x_t(t,:)'+Gam*z(t,:)'+kbar*z1(:,t))';
      WW = WW+Phibb0'*Phibb0;
      WZ = WZ+Phibb0'*ibbar*z1(:,t);
      Phibb0 = Phibb0*Phib0;
      Phib(t*l+1:(t+1)*l,:)=Phib0*Phib((t-1)*l+1:t*l,:)
 
   end
else
   for t = 1:n
      z1(:,t) = y(t,:)'-H*x_t(t,:)';
      x_t(t+1,:) = (Phi*x_t(t,:)'+kbar*z1(:,t))';
      WW = WW+Phibb0'*Phibb0;
      WZ = WZ+Phibb0'*ibbar*z1(:,t);
      Phibb0 = Phibb0*Phib0;
      Phib(t*l+1:(t+1)*l,:)=Phib0*Phib((t-1)*l+1:t*l,:)
 
   end
end
 
P_T=zeros(l*n,l)
x_T=zeros(n,dim)
R_T=zeros((n+1)*l,l)
r_T=zeros(n+1,l)
 
for t=n:-1:1
   r_T(t,:)=(Hp_ibbar*z1(:,t)+Phib0'*r_T(t+1,:)')'
   R_T(l*(t-1)+1:l*t,:)=Hp_ibbar*H+Phib0'*R_T(l*t+1:l*(t+1),:)*Phib0
end
V1_N=(eye(l,l)-pbar*R_T(1:l,:))*Phib(l+1:2*l,:)
 
select nonstat
 
case 0 then
  // stationary system
 
   if sum(abs(x0)) == 0 then
      nx0=x0
   else
      evals=spec(Sigm-pbar)
      if abs(emin(evals)) < grocer_e4_zeps then
         warning('Sigm-pbar is singular or near singular')
         nx0=pinv(Sigm-pbar)*x0
      else
         nx0=pinv(Sigm-pbar)*x0
      end
   end
 
   P1_N=pbar-pbar*R_T(1:l,:)*pbar+V1_N*inv(inv(Sigm+pbar)+WW)*V1_N'
   x1_N=pbar*r_T(1,:)'+V1_N*P1_N*(nx0+WZ)
 
   for t=n:-1:1
      V_T=(eye(l,l)-pbar*R_T(l*t+1:l*(t+1),:))*Phib(t*l+1:(t+1)*l,:)
      x_T(t,:)=x_t(t,:)+(pbar*r_T(t,:)'+V_T*x1_N)'
      P_T=pbar-pbar*R_T(l*(t-1)+1:l*t,:)*pbar+V_T*P1_N*V_T'
   end
 
 
  //
case 2 then
  // non stationary system
 
   V1_N=(eye(l,l)-pbar*R_T(1:l,:))
   P1_N=pbar-pbar*R_T(1:l,:)*pbar+V1_N*inv(WW)*V1_N'
   x1_N=pbar*r_T(1,:)'+V1_N*P1_N*WZ
 
   for t=n:-1:1
      V_T=(eye(l,l)-pbar*R_T(l*t+1:l*(t+1),:))*Phib(t*l+1:(t+1)*l,:)
      x_T(t,:)=x_t(t,:)+(pbar*r_T(t,:)'+V_T*x1_N)'
      P_T=pbar-pbar*R_T(l*(t-1)+1:l*t,:)*pbar+V_T*P1_N*V_T'
   end
 
else
  // partially stationary
   if sum(abs(x0)) == 0 then
      nx0=x0
   else
      evals=spec(eye(l,l)-iSigm*pbar)
      if abs(emin(evals)) < grocer_e4_zeps then
         warning('I-iSigm*pbar is singular or near singular')
         nx0=iSigm*pinv(eye(l,l)-iSigm*pbar)*x0
      else
         nx0=iSigm*inv(eye(l,l)-iSigm*pbar)*x0
      end
   end
 
   P1_N=pbar-pbar*R_T(1:l,:)*pbar+V1_N*inv(iSigm*inv(eye(l,l)+iSigm*pbar)+WW)*V1_N'
   x1_N=pbar*r_T(1,:)'+V1_N*P1_N*(nx0+WZ)
 
   for t=n:-1:1
      V_T=(eye(l,l)-pbar*R_T(l*t+1:l*(t+1),:))*Phib(t*l+1:(t+1)*l,:)
      x_T(t,:)=x_t(t,:)+(pbar*r_T(t,:)'+V_T*x1_N)'
      P_T=pbar-pbar*R_T(l*(t-1)+1:l*t,:)*pbar+V_T*P1_N*V_T'
   end
 
end
 
z_T=x_T*H'+z*D'
 
endfunction
 
