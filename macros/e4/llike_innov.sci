function [f,g]=llike_innov(theta,theta2mat,z,u0)
 
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
g=zeros(np,1)
 
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
 
   for i=1:np
      [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dv(theta,theta2mat,i);
      dPhib=dPhi-dE*H-E*dH
 
      if vcond == 'lyap' then
         dPhiz=dPhi*Sigm*Phi'
         dQb=dE*Q*E'
         [dx0,dSigmi]=djccl(Phi,dPhiz+dPhiz'+dQb+E*dQ*E'+dQb',0,Gam*u0')
         dP0   = lyapunov(Phi, dPhiz +dPhiz' +dQb +E*dQ*E' +dQb');
 
         if econd == 1 | econd == 4 then
            IPhi = pinv(eye(l,l)-Phi);
            dx0 = IPhi*(dPhi*IPhi*Gam + dGam)*u0;
         end
 
      elseif or(vcond == ['djong' ; 'idjong']) then
         [x1,P1]=djccl(Phi+dPhi*deps,(E+dE*deps)*(Q+dQ*deps)...
          *((E+dE*deps)'),0,(Gam+dGam*deps)*u0);
         dSigmi=(P1-Sigm)/deps
         dx0=x1-x0
      end
      dSigm(:,l*(i-1)+1:l*i)=dSigmi
 
      dPhib0=zeros(l,nx)
      g(i)=g(i)+n*0.5*trace(iQ*dQ)
 
      for t=1:n
         x0=x0_3d(:,t)
         dz1=-dH*x0-H*dx0-dD*z(t,m+1:m+r)'
         dx1=dPhi*x0+Phi*dx0+dGam*z(t,m+1:m+r)'+dE*z1(:,t)+E*dz1
         dHPhi=dH*Phib0+H*dPhib0
         dWW(:,l*(i-1)+1:l*i)=dWW(:,l*(i-1)+1:l*i)+dHPhi'*iQ*HPhi-HPhi'*iQ*dQ*iQ*HPhi+...
         HPhi'*iQ*dHPhi
         dWZ(:,i)=dWZ(:,i)+dHPhi'*iQ*z1(:,t)-HPhi'*iQ*dQ*iQ*z1(:,t)+HPhi'*iQ*dz1
         dPhib0=dPhib0*Phib+Phib0*dPhib
         dx0=dx1
         z1i=z1(:,t)'*iQ
         g(i)=g(i)+z1i*dz1-0.5*z1i*dQ*z1i'
      end
 
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
 
   for i=1:np
 
      [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dv(theta,theta2mat,i);
      dPhib=dPhi-dE*H-E*dH
 
      if vcond == 'lyap' then
         dPhiz=dPhi*Sigm*Phi'
         dQb=dE*Q*E'
         [dx0,dSigmi]=djccl(Phi,dPhiz+dPhiz'+dQb+E*dQ*E'+dQb',0,[])
 
      elseif or(vcond == ['djong' ; 'idjong']) then
         [x1,P1]=djccl(Phi+dPhi*deps,(E+dE*deps)*(Q+dQ*deps)...
          *((E+dE*deps)'),0,[]);
         dSigmi=(P1-Sigm)/deps
         dx0=x1-x0
      end
      dSigm(:,l*(i-1)+1:l*i)=dSigmi
 
      dPhib0=zeros(l,nx)
      g(i)=g(i)+n*0.5*trace(iQ*dQ)
 
      for t=1:n
 
         x0=x0_3d(:,t)
         Phib0=Phib0_3d(:,l*(t-1)+1:l*t)
         HPhi=H*Phib0
         dz1=-dH*x0-H*dx0
         dx1=dPhi*x0+Phi*dx0+dE*z1(:,t)+E*dz1
         dHPhi=dH*Phib0+H*dPhib0
         dWW(:,l*(i-1)+1:l*i)=dWW(:,l*(i-1)+1:l*i)+dHPhi'*iQ*HPhi-HPhi'*iQ*dQ*iQ*HPhi+...
         HPhi'*iQ*dHPhi
         dWZ(:,i)=dWZ(:,i)+dHPhi'*iQ*z1(:,t)-HPhi'*iQ*dQ*iQ*z1(:,t)+HPhi'*iQ*dz1
         dPhib0=dPhib0*Phib+Phib0*dPhib
         dx0=dx1
         z1i=z1(:,t)'*iQ
         g(i)=g(i)+z1i*dz1-0.5*z1i*dQ*z1i'
 
      end
 
   end
 
end
ff = 2*n*sum(log(diag(U)))+sum((iU*z1).^2);
if or(isnan([WW,WZ]),1)|or(isinf([WW,WZ]),1) then
   warning('Initial conditions has become meaningless');
   write(%io(2),'trying to overcome this problem','(a)')
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
         lnew=l-nk
         dSigmnew=zeros(lnew,lnew*np)
         dWWnew=zeros(lnew,lnew*np)
         dWZnew=zeros(lnew,np)
         for i=1:np
            dSigmnew(:,lnew*(i-1)+1:lnew*i)=N'*dSigm(:,l*(i-1)+1:l*i)*N
            dWWnew(:,lnew*(i-1)+1:lnew*i)=N'*dWW(:,l*(i-1)+1:l*i)*N
            dWZnew(:,i)=N'*dWZ(:,i)
         end
         dSigm=dSigmnew
         dWW=dWWnew
         dWZ=dWZnew
         l=lnew
 
      //
      end
   end
 
   M = cholp1(Sigm,0);
   T = cholp1(eye(size(M,1),size(M,1))+M*WW*M',0);
   ff = ff+2*sum(log(diag(T)));
   for i=1:np
      g(i)=g(i)+0.5*trace(pinv(eye(l,l)+Sigm*WW)*(dSigm(:,l*(i-1)+1:l*i)*WW+Sigm*dWW(:,l*(i-1)+1:l*i)))
   end
 
   if econd == 'ml' then
      T = cholp1(WW,0);
      ff = ff-sum((T'\WZ).^2);
      iWWmWZ=pinv(WW)*WZ
 
      for i=1:np
         g(i)=g(i)-dWZ(:,i)'*iWWmWZ+0.5*iWWmWZ'*dWW(:,l*(i-1)+1:l*i)*iWWmWZ
      end
 
   else
      ff = ff-sum((T'\(M*WZ)).^2);
      iSigm=pinv(Sigm)
      iWWmWZ=pinv(iSigm+WW)*WZ
 
      for i=1:np
         g(i)=g(i)-dWZ(:,i)'*iWWmWZ+0.5*iWWmWZ'*(dWW(:,l*(i-1)+1:l*i)-iSigm*dSigm(:,l*(i-1)+1:l*i)*iSigm)*iWWmWZ
      end
 
   end
 
 
case 2 then
  // non stationary system
 
   T = cholp1(WW,0);
   ff = ff+2*sum(log(diag(T)))-sum((T'\WZ).^2);
   iT=pinv(T,zeps)
   iWW=iT'*iT
   for i=1:np
      g(i)=g(i)+0.5*trace(iWW*dWW(:,l*(i-1)+1:l*i))-dWZ(:,i)'*iWW*WZ+0.5*WZ'*iWW'*dWW(:,l*(i-1)+1:l*i)*iWW*WZ
   end
 
else
  // partially stationary
 
   [Ns,S,Ns] = svd(Sigm);
   T = cholp1(iSigm+WW,0);
   ff = ff+2*sum(log(diag(T)))+sum(log(S(S>zeps)));
   iSigWW=pinv(iSigm+WW,zeps)
 
   for i=1:np
      g(i)=g(i)+0.5*trace(iSigWW*(dWW(:,l*(i-1)+1:l*i)-iSigm*dSigm(:,l*(i-1)+1:l*i)*iSigm))+...
          0.5*trace(iSigm*dSigm(:,l*(i-1)+1:l*i))
   end
 
   if econd == 'ml' then
      T = cholp1(WW,0);
      iWWmWZ=pinv(WW)*WZ
      for i=1:np
         g(i)=g(i)-dWZ(:,i)'*iWWmWZ+0.5*iWWmWZ'*dWW(:,l*(i-1)+1:l*i)*iWWmWZ
      end
   else
      iSigWWmWZ=iSigWW*WZ
      for i=1:np
         g(i)=g(i)-dWZ(:,i)'*iSigWWmWZ+0.5*iSigWWmWZ'*(dWW(:,l*(i-1)+1:l*i)-iSigm*dSigm(:,l*(i-1)+1:l*i)*iSigm)*iSigWWmWZ
      end
   end
   ff = ff-sum((T'\WZ).^2);
 
end
 
f = .5*(ff+n*m*log(2*%pi));
 
endfunction
 
