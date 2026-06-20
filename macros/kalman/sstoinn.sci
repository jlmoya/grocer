function [E,Q,U,iU,P]=sstoinn(Phi,E,H,C,Q,S,R)
 
//
// SSTOINN  - Transforms a general SS noise structure to an innovations structure.
//        [E,Q,U,iU,P] = sstoinn(Phi, E, H, C, Q, S, R)
//
//   U = cholp(Q)
//   iU = inv(U')
//   P  < Solution of ARE (algebraic Riccati equation)
 
 
scaleb = grocer_E4OPTION(2);
zeps = grocer_E4OPTION(15);
 
l = size(Phi,1);
m = size(H,1);
N = C*R*C';
iN = pinv(C*R*C');
ESCt = E*S*C';
M = E*Q*E'-ESCt*iN*ESCt';
 
if trace(M)<zeps then
  P = zeros(l,l);
else
  A = Phi-ESCt*iN*H;
 
  [U,S,V] = svd([N;-H']);
  T = [U(m+1:l+m,m+1:l+m)'*A',zeros(l,l);-M,eye(l,l)];
  Y = [U(m+1:l+m,m+1:l+m)',U(1:m,m+1:l+m)'*H;zeros(l,l),A];
 
  //!! Eig with 2 rhs args: generalized eigen assumed. Check
  [%v1$1,%v1$2,W] = spec(T,Y);
 
  d = diag(%v1$1./%v1$2);
  d = diag(d);
  %v1 = abs(d)
 
  //! next test may  probably be simplified
  if min(size(%v1))==1 then
    [e,index]=gsort(-%v1,'g','d');e = -e
  else
    [e,index]=sort(-%v1,'r');e = -e
  end
  WW = W(:,index(1:l));
  P = real(WW(l+1:2*l,:)*pinv(WW(1:l,:)));
end
 
Q = H*P*H'+N;
if scaleb then
 
  U = cholp(Q,abs(Q));
else
  U = cholp(Q);
end
iU = eye(m,m)/U';
E = (Phi*P*H'+ESCt)*iU'*iU;
 
endfunction
