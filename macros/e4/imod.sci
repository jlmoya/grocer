function [dts,corrm,varm,Im]=imod(theta,theta2mat,z,aprox,varargin)
 
// PURPOSE: Computes the exact information matrix under
// normality for a model written in SS form
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * z = matrix of endogenous variables
// * aprox = a scalar; If aprox = 0, computes the approximation
// of Watson and Engle (1983).
// ------------------------------------------------------------
// OUTPUT:
// * corrm = (npxnp) correlation matrix
// * dts = (npx1) vector of standard deviations
// * varm = (npxnp) covariance matrix
// * Im = (npxnp) information matrix
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
// userf > contains the names of the user functions required to obtain the system
// matrices and their derivatives (only for user models).
 
[nargout,nargin] = argn(0)
if nargin<3 then
  error(' Incorrect number of arguments');
end
 
if nargin<4 then
  aprox = 0;
elseif aprox then
  warning('Approximate computation of information matrix');
end
 
grocer_E4OPTION = grocer_E4OPTION
grocer_E4OPTION('filter') = 'kalm'
grocer_e4_zeps=grocer_E4OPTION('deriv eps')
 
[Phi,Gam,E,H,D,C,Q,S,R] = theta2ss(theta,theta2mat,varargin(:));
n = size(z,1);
m = size(H,1);
r = size(z,2)-m;
 
if (grocer_E4OPTION('econd')=='ml')&(~aprox) then
  mV = 1;
else
  mV = 0;
end
 
np=grocer_e4param.np
 
[x0,P0] = lfmodini(Phi,Gam,E,H,D,C,Q,S,R,z,mV);
p  = size(P0,1);
if isempty(E) then
   E=zeros(p,p)
end
if isempty(C) then
   C=zeros(m,m)
end
if isempty(R) then
   R=zeros(m,m)
end
if isempty(Q) then
   Q=zeros(p,p)
end
if isempty(S) then
   S=zeros(size(Q,1),size(R,1))
end
 
if isempty(Gam) then
   Gam=zeros(p,r)
end
if isempty(D) then
   D=zeros(m,r)
end
 
CRCt = C*R*C';
ESCt = E*S*C';
EQEt = E*Q*E';
 
CRCt = C*R*C';
ESCt = E*S*C';
EQEt = E*Q*E';
 
Im = zeros(np,np);
 
dPhii = zeros(p*np,p);
sGam = size(Gam,1);
dGami = zeros(sGam*np,size(Gam,2));
sE = size(E,1);
dEi = zeros(sE*np,size(E,2));
dHi = zeros(m*np,p);
sD = size(D,1);
dDi = zeros(sD*np,size(D,2));
sC = size(C,1);
dCi = zeros(sC*np,size(C,2));
sQ = size(Q,1);
dQi = zeros(sQ*np,size(Q,2));
sS = size(S,1);
dSi = zeros(sS*np,size(S,2));
sR = size(R,1);
dRi = zeros(sR*np,size(R,2));
 
dx0i = zeros(p*np,1);
dP0i = zeros(p*np,p);
dB1i = zeros(m*np,m);
 
if mV then
  x00 = x0;
  P00 = P0;
  Phibb0 = eye(p,p);
  dPhibb0 = zeros(p*np,p);
  WW = zeros(p,p);
  WZ = zeros(p,1);
  dWW = zeros(p*np,p);
  dWZ = zeros(p*np,1);
end
 
if aprox|mV then
  dz1i = zeros(m*np,1);
end
 
if ~aprox then
  //
  dK1i = zeros(p*np,m);
  Pc11 = zeros(p,p);
  Pc21 = zeros(p*np,p);
  Pc23 = zeros(p*(np+1)*np/2,p);
 
  if r|mV then
    xc = x0;
    dxc = zeros(p*np,1);
    dzc = zeros(m*np,1);
  else
    Pc11 = Pc11+x0*x0';
  end
  //
end
 
for i = 1:np
  //
  j = i-1;
  [dPhii_aux,dGam,dEi_aux,dHi_aux,dD,dCi_aux,dQi_aux,dSi_aux,dRi_aux]=ss_dv(theta,theta2mat,i,varargin(:));
  dPhii(j*p+1:i*p,:)=dPhii_aux
  dEi(j*sE+1:i*sE,:)=dEi_aux
  dHi(j*m+1:i*m,:)=dHi_aux
  dCi(j*sC+1:i*sC,:)=dCi_aux
  dQi(j*sQ+1:i*sQ,:)=dQi_aux
  dSi(j*sS+1:i*sS,:)=dSi_aux
  dRi(j*sR+1:i*sR,:)=dRi_aux
 
  if r then
    dGami(j*sGam+1:i*sGam,:) = dGam;
    dDi(j*sD+1:i*sD,:) = dD;
  end
 
  [dx0i_aux,dP0i_aux]=gmodini(Phi,dPhii(j*p+1:i*p,:),Gam,dGami(j*sGam+1:i*sGam,:),E,dEi(j*sE+1:i*sE,:),H,dHi(j*m+1:i*m,:),D,dDi(j*sD+1:i*sD,:),C,dCi(j*sC+1:i*sC,:),Q,dQi(j*sQ+1:i*sQ,:),S,dSi(j*sS+1:i*sS,:),R,dRi(j*sR+1:i*sR,:),z,mV);
  dx0i(j*p+1:i*p,:)=dx0i_aux
  dP0i(j*p+1:i*p,:)=dP0i_aux
 
  if ~aprox then
    //
    if (~r)&(~mV) then
      //
      Pc21(j*p+1:i*p,:) = dx0i(j*p+1:i*p,:)*x0';
 
      for k = 1:i
        l = k-1;
        ptri = (j*i/2+l)*p+1;
        ptrf = ptri+p-1;
 
        Pc23(ptri:ptrf,:) = dx0i(j*p+1:i*p,:)*dx0i(l*p+1:k*p,:)';
      end
      //
    elseif ~mV then
      dxc(j*p+1:i*p,:) = dx0i(j*p+1:i*p,:);
    end
    //
  end
  //
end
 
for t = 1:grocer_e4_T
  // main loop
  //
  B1 = H*P0*H'+CRCt;
  iB1 = pinv(B1,grocer_e4_zeps);
 
  K1 = (Phi*P0*H'+ESCt)*iB1;
  Phib = Phi-K1*H;
 
  if r then
    Gamb = Gam-K1*D;
  end
 
  if mV then
    HPhi = H*Phibb0;
      z1 = z(t,1:m)'-H*x0-(D+0)*(z(t,m+1:m+r)+0)';
  end
 
  for i = 1:np
    //
    j = i-1;
    dB1i(j*m+1:i*m,:) = dHi(j*m+1:i*m,:)*P0*H'+...
      H*dP0i(j*p+1:i*p,:)*H'+H*P0*dHi(j*m+1:i*m,:)'+...
      dCi(j*sC+1:i*sC,:)*R*C'+C*dRi(j*sR+1:i*sR,:)*C'+C*R*dCi(j*sC+1:i*sC,:)';
 
    if aprox then
      //
      dK1i = (dPhii(j*p+1:i*p,:)*P0*H'+...
         Phi*dP0i(j*p+1:i*p,:)*H'+...
         Phi*P0*dHi(j*m+1:i*m,:)'+dEi(j*sE+1:i*sE,:)*S*C'+...
         E*dSi(j*sS+1:i*sS,:)*C'+E*S*dCi(j*sC+1:i*sC,:)'-K1*dB1i(j*m+1:i*m,:))*iB1;
 
      dPhibi = dPhii(j*p+1:i*p,:)-dK1i*H-K1*dHi(j*m+1:i*m,:);
 
      if r then
        dz1i(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*x0...
           -H*dx0i(j*p+1:i*p,:)...
           -dDi(j*sD+1:i*sD,:)*z(t,m+1:m+r)';
 
        dGambi = dGami(j*sGam+1:i*sGam,:)-dK1i*D-K1*dDi(j*sD+1:i*sD,:);
 
        dx0i(j*p+1:i*p,:) = dPhibi*x0+...
           Phib*dx0i(j*p+1:i*p,:)+dGambi*z(t,m+1:m+r)'+...
           dK1i*z(t,1:m)';
      else
        dz1i(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*x0...
           -H*dx0i(j*p+1:i*p,:);
 
        dx0i(j*p+1:i*p,:) = dPhibi*x0+...
           Phib*dx0i(j*p+1:i*p,:)+dK1i*z(t,1:m)';
      end
 
      dP0i(j*p+1:i*p,:) = dPhibi*P0*Phib'+...
         Phib*dP0i(j*p+1:i*p,:)*Phib'+Phib*P0*dPhibi'+...
         dEi(j*sE+1:i*sE,:)*Q*E'+E*dQi(j*sQ+1:i*sQ,:)*E'+E*Q*dEi(j*sE+1:i*sE,:)'+...
         dK1i*CRCt*K1'+K1*dCi(j*sC+1:i*sC,:)*R*C'*K1'+K1*C*dRi(j*sR+1:i*sR,:)*C'*K1'+...
         K1*C*R*dCi(j*sC+1:i*sC,:)'*K1'+K1*CRCt*dK1i'-dK1i*ESCt'-...
         K1*dCi(j*sC+1:i*sC,:)*S'*E'-K1*C*dSi(j*sS+1:i*sS,:)'*E'-...
         K1*C*S'*dEi(j*sE+1:i*sE,:)'-dEi(j*sE+1:i*sE,:)*S*C'*K1'-...
         E*dSi(j*sS+1:i*sS,:)*C'*K1'-E*S*dCi(j*sC+1:i*sC,:)'*K1'-ESCt*dK1i';
 
      for k = 1:i
        l = k-1;
        Im(i,k) = Im(i,k)+.5*trace(dB1i(j*m+1:i*m,:)'...
           *iB1*(dB1i(l*m+1:k*m,:)'*iB1))+...
           dz1i(j*m+1:i*m,:)'*iB1*dz1i(l*m+1:k*m,:);
      end
      //
    else
      //
      dK1i(j*p+1:i*p,:) = (dPhii(j*p+1:i*p,:)*P0*H'+...
         Phi*dP0i(j*p+1:i*p,:)*H'+Phi*P0*dHi(j*m+1:i*m,:)'+dEi(j*sE+1:i*sE,:)*S*C'+...
         E*dSi(j*sS+1:i*sS,:)*C'+E*S*dCi(j*sC+1:i*sC,:)'-...
         K1*dB1i(j*m+1:i*m,:))*iB1;
 
      dPhibi = dPhii(j*p+1:i*p,:)-dK1i(j*p+1:i*p,:)*H...
         -K1*dHi(j*m+1:i*m,:);
 
      if mV then
        if r then
          dz1i(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*x0...
             -H*dx0i(j*p+1:i*p,:)-dDi(j*sD+1:i*sD,:)*z(t,m+1:m+r)';
 
          dGambi = dGami(j*sGam+1:i*sGam,:)-dK1i(j*p+1:i*p,:)*D-K1*dDi(j*sD+1:i*sD,:);
 
          dx0i(j*p+1:i*p,:) = dPhibi*x0+...
             Phib*dx0i(j*p+1:i*p,:)+dGambi*z(t,m+1:m+r)'+...
             dK1i(j*p+1:i*p,:)*z(t,1:m)';
        else
          dz1i(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*x0...
            -H*dx0i(j*p+1:i*p,:);
 
          dx0i(j*p+1:i*p,:) = dPhibi*x0+Phib*dx0i(j*p+1:i*p,:)+...
            dK1i(j*p+1:i*p,:)*z(t,1:m)';
        end
      end
 
      dP0i(j*p+1:i*p,:) = dPhibi*P0*Phib'+Phib*dP0i(j*p+1:i*p,:)*Phib'...
        +Phib*P0*dPhibi'+dEi(j*sE+1:i*sE,:)*Q*E'+E*dQi(j*sQ+1:i*sQ,:)*E'+E*Q*dEi(j*sE+1:i*sE,:)'+...
        dK1i(j*p+1:i*p,:)*CRCt*K1'+K1*dCi(j*sC+1:i*sC,:)*R*C'*K1'+K1*C*dRi(j*sR+1:i*sR,:)*C'*K1'+...
        K1*C*R*dCi(j*sC+1:i*sC,:)'*K1'+K1*CRCt*dK1i(j*p+1:i*p,:)'...
        -dK1i(j*p+1:i*p,:)*ESCt'-K1*dCi(j*sC+1:i*sC,:)*S'*E'...
        -K1*C*dSi(j*sS+1:i*sS,:)'*E'-K1*C*S'*dEi(j*sE+1:i*sE,:)'-dEi(j*sE+1:i*sE,:)*S*C'*K1'...
       -E*dSi(j*sS+1:i*sS,:)*C'*K1'-E*S*dCi(j*sC+1:i*sC,:)'*K1'-ESCt*dK1i(j*p+1:i*p,:)';
 
      Phibi = dPhii(j*p+1:i*p,:)-K1*dHi(j*m+1:i*m,:);
 
      if r&(~mV) then
        dzc(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*xc...
        -H*dxc(j*p+1:i*p,:)-dDi(j*sD+1:i*sD,:)*z(t,m+1:m+r)';
 
        dxc(j*p+1:i*p,:) = Phibi*xc+Phib*dxc(j*p+1:i*p,:)+...
          (dGami(j*sGam+1:i*sGam,:)-K1*dDi(j*sD+1:i*sD,:))*z(t,m+1:m+r)';
      end
 
      for k = 1:i
        //
        l = k-1;
        ptri = (j*i/2+l)*p+1;
        ptrf = ptri+p-1;
 
        Phibj = dPhii(l*p+1:k*p,:)-K1*dHi(l*m+1:k*m,:);
 
        Bij = dHi(j*m+1:i*m,:)*Pc11*dHi(l*m+1:k*m,:)'+...
           H*Pc21(j*p+1:i*p,:)*dHi(l*m+1:k*m,:)'+...
           dHi(j*m+1:i*m,:)*Pc21(l*p+1:k*p,:)'*H'+...
           H*Pc23(ptri:ptrf,:)*H';
 
        Pc23(ptri:ptrf,:) = Phibi*Pc11*Phibj'+Phib*Pc21(j*p+1:i*p,:)*Phibj'+...
           Phibi*Pc21(l*p+1:k*p,:)'*Phib'+Phib*Pc23(ptri:ptrf,:)*Phib'+...
           dK1i(j*p+1:i*p,:)*B1*dK1i(l*p+1:k*p,:)';
 
        if r&(~mV) then
          Im(i,k) = Im(i,k)+.5*trace(dB1i(j*m+1:i*m,:)'*iB1*(dB1i(l*m+1:k*m,:)'*iB1))...
            +trace(iB1*(Bij+dzc(j*m+1:i*m,:)*dzc(l*m+1:k*m,:)'));
        else
          Im(i,k) = Im(i,k)+.5*trace(dB1i(j*m+1:i*m,:)'*iB1*(dB1i(l*m+1:k*m,:)'*iB1))+trace(iB1*Bij);
        end
        //
      end
      //
    end
 
    if mV then
      dHPhi = dHi(j*m+1:i*m,:)*Phibb0+H*dPhibb0(j*p+1:i*p,:);
      dWW(j*p+1:i*p,:) = dWW(j*p+1:i*p,:)+dHPhi'*iB1*HPhi-HPhi'*iB1*dB1i(j*m+1:i*m,:)*iB1*HPhi+HPhi'*iB1*dHPhi;
      dWZ(j*p+1:i*p,:) = dWZ(j*p+1:i*p,:)+dHPhi'*iB1*z1-HPhi'*iB1*dB1i(j*m+1:i*m,:)*iB1*z1+HPhi'*iB1*dz1i(j*m+1:i*m,:);
      dPhibb0(j*p+1:i*p,:) = dPhibi*Phibb0+Phib*dPhibb0(j*p+1:i*p,:);
    end
    //
  end
  // i
 
  if mV then
    WW = WW+HPhi'*iB1*HPhi;
    WZ = WZ+HPhi'*iB1*z1;
    Phibb0 = Phib*Phibb0;
  end
 
  if aprox then
     x0 = Phib*x0+(Gamb+0)*(z(t,m+1:m+r)+0)'+K1*z(t,1:m)';
  else
    //
     if mV then
        x0 = Phib*x0+(Gamb+0)*(z(t,m+1:m+r)+0)'+K1*z(t,1:m)';
     end
 
     for i = 1:np
        j = i-1;
        Phibi = dPhii(j*p+1:i*p,:)-K1*dHi(j*m+1:i*m,:);
        Pc21(j*p+1:i*p,:) = Phibi*Pc11*Phi'+Phib*Pc21(j*p+1:i*p,:)*Phi'+dK1i(j*p+1:i*p,:)*B1*K1';
     end
 
     Pc11 = Phi*Pc11*Phi'+K1*B1*K1';
 
     if r&(~mV) then
        xc = Phi*xc+Gam*z(t,m+1:m+r)';
     end
    //
  end
 
  P0 = Phib*P0*Phib'+EQEt+K1*CRCt*K1'-K1*ESCt'-ESCt*K1';
  //
end
// t
 
 
if mV then
  //
  WW = pinv(WW,grocer_e4_zeps);
  xc = WW*WZ;
  for i = 1:np
    j = i-1;
    dxc(j*p+1:i*p,:) = WW*(dWZ(j*p+1:i*p,:)-dWW(j*p+1:i*p,:)*xc);
  end
  xc = xc+x00;
  P0 = P00;
 
  for t = 1:n
    //
    B1 = H*P0*H'+CRCt;
//    U = cholp(B1,grocer_e4_scaleb*abs(B1));
    iB1 = pinv(B1,grocer_e4_zeps);
    K1 = (Phi*P0*H'+ESCt)*iB1;
    Phib = Phi-K1*H;
    if r then
      Gamb = Gam-K1*D;
    end
 
    for i = 1:np
      //
      j = i-1;
 
      Phibi = dPhii(j*p+1:i*p,:)-K1*dHi(j*m+1:i*m,:);
 
      if r then
        dzc(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*xc-H*dxc(j*p+1:i*p,:)-dDi(j*sD+1:i*sD,:)*z(t,m+1:m+r)';
 
        dxc(j*p+1:i*p,:) = Phibi*xc+Phib*dxc(j*p+1:i*p,:)+(dGami(j*sGam+1:i*sGam,:)-K1*dDi(j*sD+1:i*sD,:))*z(t,m+1:m+r)';
      else
        dzc(j*m+1:i*m,:) = -dHi(j*m+1:i*m,:)*xc-H*dxc(j*p+1:i*p,:);
        dxc(j*p+1:i*p,:) = Phibi*xc+Phib*dxc(j*p+1:i*p,:);
      end
 
      for k = 1:i
        l = k-1;
        Im(i,k) = Im(i,k)+dzc(l*m+1:k*m,:)'*iB1*dzc(j*m+1:i*m,:);
      end
      //
    end
 
    if r then
      xc = Phi*xc+Gam*z(t,m+1:m+r)';
    else
      xc = Phi*xc;
    end
 
    P0 = Phib*P0*Phib'+EQEt+K1*CRCt*K1'-K1*ESCt'-ESCt*K1';
    //
  end
  //
end
 
Im = Im+tril(Im,-1)'
 
if min(spec(Im))<=0 then
  warning('Information matrix sd+ o d-. Pseudo-inverse computed');
end
 
varm = pinv(Im,grocer_e4_zeps);
dts = sqrt(diag(varm));
invdts= diag(ones(size(dts,1),1)./dts)
corrm = invdts*varm*invdts
 
endfunction
