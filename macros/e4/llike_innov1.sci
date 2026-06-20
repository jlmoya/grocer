function f=llike_innov1(theta,theta2mat,z,u0)
 
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
// Copyright Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
// adapted from various Matlab programs developped by
// Jaime Terceiro, 1997
 
[nargout,nargin] = argn(0)
 
[Phi,Gam,E,H,D,C,Q,S,R] = grocer_theta2ss(theta,theta2mat);
 
E4OPTION=grocer_E4OPTION
deps=E4OPTION('deriv eps')
zeps=E4OPTION('gen tol')
scaleb=E4OPTION('scale B')
vcond=E4OPTION('vcond')
econd=E4OPTION('econd')
 
np=size(theta,1)
n = size(z,1);
l = size(Phi,1);
r = max([size(Gam,2),size(D,2)]);
m = size(H,1)
 
Q = C*Q*C';
E = E*pinv(C);
U = cholp1(Q,scaleb*abs(Q));
iU = eye(m,m)/U';
iQ=iU'*iU
[x0,Sigm,iSigm,nonstat] = djccl(Phi,E*Q*E',0,Gam*u0');
 
if vcond == 'lyap' & nonstat >0 then
   vcond = 'djong'
end
 
x00=x0
nx=size(x0,1)
WW = zeros(l,l);
WZ = zeros(l,1);
Phib = Phi-E*H;
Phib0 = eye(l,l)
 
N= eye(l,l);
ff = 0;
 
z1 = zeros(m,n);
x0_3d=ones(1,n+1) .*. x00
Phib0_3d=[Phib0 zeros(l,l*(n+1))]
dSigm=zeros(l,l*np)
dWW=zeros(l,l*np)
dWZ=zeros(l,np)
 
 
if r then
   for t = 1:n
   // main loop
      z1(:,t) = z(t,1:m)'-H*x0-D*z(t,m+1:m+r)';
      x0 = Phi*x0+Gam*z(t,m+1:m+r)'+E*z1(:,t);
      HPhi=H*Phib0
      WW = WW+HPhi'*iQ*HPhi;
      WZ = WZ+HPhi'*iQ*z1(:,t);
      Phib0 = Phib0*Phib;
      x0_3d(:,t+1)=x0
      Phib0_3d(:,l*t+1:l*(t+1))=Phib0
   end
 
else
 
   for t = 1:n
      z1(:,t) = z(t,:)'-H*x0;
      x0 = Phi*x0+E*z1(:,t);
      HPhi=H*Phib0
      Phib0 = Phib0*Phib;
      WW = WW+HPhi'*iQ*HPhi;
      WZ = WZ+HPhi'*iQ*z1(:,t);
      x0_3d(:,t+1)=x0
      Phib0_3d(:,l*t+1:l*(t+1))=Phib0
   end
 
 
end
ff = 2*n*sum(log(diag(U)))+sum((iU*z1).^2);
if or(isnan([WW,WZ]),1)|or(isinf([WW,WZ]),1) then
   warning('Initial conditions has become meaningless; trying to overcome this problem');
   f=.5*(ff+n*m*log(2*%pi));
   return
end
 
select nonstat
case 0 then
   // stationary system
   //
   [Ns,S,Ns] = svd(Sigm);
 
   k =find(diag(S)<zeps)
   nk=size(k,2)
   if nk<l then
      if nk then
      //
         N = Ns(:,1:k(1)-1);
         Sigm = S(1:k(1)-1,1:k(1)-1);
         WW = N'*WW*N;
         WZ = N'*WZ;
      //
      end
   end
 
   M = cholp1(Sigm,0);
   T = cholp1(eye(size(M,1),size(M,1))+M*WW*M',0);
   ff = ff+2*sum(log(diag(T)));
 
   if econd == 'ml' then
      T = cholp1(WW,0);
      ff = ff-sum((T'\WZ).^2);
 
   else
      ff = ff-sum((T'\(M*WZ)).^2);
   end
 
 
case 2 then
  // non stationary system
 
   T = cholp1(WW,0);
   ff = ff+2*sum(log(diag(T)))-sum((T'\WZ).^2);
 
else
  // partially stationary
 
   [Ns,S,Ns] = svd(Sigm);
   T = cholp1(iSigm+WW,0);
   ff = ff+2*sum(log(diag(T)))+sum(log(S(S>zeps)));
 
   if econd == 'ml' then
      T = cholp1(WW,0);
   end
   ff = ff-sum((T'\WZ).^2);
 
end
 
f = .5*(ff+n*m*log(2*%pi));
 
endfunction
 
