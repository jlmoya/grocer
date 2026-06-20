function [x_T,P_T,z_T]=smooth_innov(theta,theta2mat,z,u0)
 
// PURPOSE: calculation of smoothed state and measure vectors
// in a steady-state innovation model
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
// NOTE: the function uses the algorithm described in:
// Casals J., Jerez M. and Sotoca S. (2000): "Exact Smoothing
// for Stationary and Nonstationary Time Series", International
// Journal of Forecasting, vol. 16, pp. 59-69
// ------------------------------------------------------------
// Copyright Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
[Phi,Gam,E,H,D,C,Q,S,R] = grocer_theta2ss(theta,theta2mat);
grocer_e4_zeps=grocer_E4OPTION('deriv eps')
n = size(z,1);
l = size(Phi,1);
r = max([size(Gam,2),size(D,2)]);
m = size(H,1)
 
 
Q = C*Q*C';
E = E*pinv(C);
 
U = cholp1(Q,grocer_E4OPTION('scale B')*abs(Q));
iU = eye(m,m)/U';
 
[x0,Sigm,iSigm,nonstat] = djccl(Phi,E*Q*E',0,Gam*u0');
 
dim=size(x0,1)
WW = zeros(l,l);
WZ = zeros(l,1);
Phib0 = Phi-E*H
Phib = ones(n+1,1) .*. eye(dim,dim);
Phibb0 = iU*H;
x_t=zeros(n+1,dim)
x_t(1,:)=x0'
 
N= eye(l,l);
 
z1 = zeros(m,n);
 
if r then
   for t = 1:n
   // main loop
      z1(:,t) = z(t,1:m)'-H*x_t(t,:)'-D*z(t,m+1:m+r)';
      x_t(t+1,:) = (Phi*x_t(t,:)'+Gam*z(t,m+1:m+r)'+E*z1(:,t))';
      WW = WW+Phibb0'*Phibb0;
      WZ = WZ+Phibb0'*iU*z1(:,t);
      Phibb0 = Phibb0*Phib0;
      Phib(t*l+1:(t+1)*l,:)=Phib0*Phib((t-1)*l+1:t*l,:)
 
   end
else
   for t = 1:n
      z1(:,t) = z(t,:)'-H*x_t(t,:)';
      x_t(t+1,:) = (Phi*x_t(t,:)'+E*z1(:,t))';
      WW = WW+Phibb0'*Phibb0;
      WZ = WZ+Phibb0'*iU*z1(:,t);
      Phibb0 = Phibb0*Phib0;
      Phib(t*l+1:(t+1)*l,:)=Phib0*Phib((t-1)*l+1:t*l,:)
 
   end
end
 
P_T=zeros(l*n,l)
x_T=zeros(n,dim)
N=eye(l,l)
 
if ~nonstat then
  // stationary system
  //
   auxm=inv(eye(l,l)+WW*Sigm)
   P_0=auxm*Sigm
   x_0= (auxm*(x0+Sigm*WZ))'
 
   [Ns,S,Ns] = svd(Sigm);
   k =find(diag(S)<grocer_E4OPTION('gen tol'))
   if size(k,2) then
      //
      if size(k,2) == size(diag(S),'*') then
         warning('the matrix of starting conditions has become nearly singular')
         if size(k,2) == 1 then
            k(1)=2
         else
            k(1)=[]
         end
      end
      N = Ns(:,1:k(1)-1);
      Sigm = S(1:k(1)-1,1:k(1)-1);
      WW = N'*WW*N;
      WZ = N'*WZ;
      //
   end
   M = cholp1(Sigm,0);
   iM=inv(M)
   T = cholp1(eye(size(M,1),size(M,1))+M*WW*M',0);
   iT=inv(T)
   P_T(1:l,:)=N*M'*iT'*iT*M*N'
   x_T(1,:)= (N*M'*iT'*iT*M*(iM*iM'*N'*x0+WZ))'
 
  //
elseif nonstat==2 then
  // non stationary system
  //
   T = cholp(WW);
   iT=inv(T)
   P_T(1:l,:)=iT'*iT
   x_T(1,:)= (P_T(1:l,:)*WZ)'
  //
else
   // partially stationary
   // à finaliser
   T = cholp(iSigm+WW);
   if grocer_E4OPTION('econd')=='ml' then
      T = cholp(WW);
   end
   iT=inv(T)
   P_T(1:l,:)=iT'*iT
   x_T(1,:)=(P_T(1:l,:)*(iSigm*x0+WZ))'
     //
end
 
for t=2:n
   x_T(t,:)=x_t(t,:)+(Phib((t-1)*l+1:t*l,:)*x_T(1,:)')'
   P_T((t-1)*l+1:t*l,:)=Phib((t-1)*l+1:t*l,:)*P_T(1:l,:)*Phib((t-1)*l+1:t*l,:)'
end
 
z_T=[x_T , z(:,m+1:m+r)]*[H' ; D']
 
endfunction
 
