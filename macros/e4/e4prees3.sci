function [f,KB]=e4prees3(theta,din,R,ix,ij)
f=[];KB=[];
[nargout,nargin] = argn(0)
//
// 7/3/97
// Copyright (c) Jaime Terceiro, 1997
 
 
[Phi,Gam,E,H,D,C,Q,S,Rm] = theta2ss(theta,din);
n = size(Phi,1);
m = size(H,1);
r = max([size(Gam,2),size(D,2)]);
 
i = ij(1);
j = ij(2);
pond = ij(3);
N = ij(4);
 
O = [H;zeros((i-1)*m,n)];
 
Phi2 = Phi;
 
for k = 1:j-1
  O(k*m+1:(k+1)*m,:) = H*Phi2;
  Phi2 = Phi2*Phi;
end
 
iO = pinv(O);
 
if ~r then
  X = iO*R(ix(2,1):ix(3,2),ix(1,1):ix(1,2));
  if pond then
    e = R(ix(2,1):ix(3,2),ix(2,1):ix(3,2))\(R(ix(2,1):ix(3,2),ix(1,1):ix(1,2))-O*X);
  else
    e = R(ix(2,1):ix(3,2),ix(1,1):ix(1,2))-O*X;
  end
 
  f = N*trace(e*e');
 
  if nargout>1 then
    O1 = O(1:(j-1)*m,:);
    e = [R(ix(2,1):ix(2,2),ix(1,1):ix(1,2))-H*X,R(ix(2,1):ix(2,2),ix(2,1):ix(2,2))];
    KB = [pinv(O1)*R(ix(3,1):ix(3,2),ix(1,1):ix(2,2))/e;e*e'];
  end
  //
else
  //
  O1 = O(1:(j-1)*m,:);
  Hid = [[D;O1*Gam],zeros(j*m,(j-1)*r)];
  for k = 2:j
    Hid((k-1)*m+1:j*m,(k-1)*r+1:k*r) = Hid(1:(j-k+1)*m,1:r);
  end
 
  A = (eye(j*m,j*m)-O*iO)*Hid;
 
  X = iO*R(ix(4,1):ix(5,2),ix(1,1):ix(3,2));
  if pond then
    e = R(ix(4,1):ix(5,2),ix(4,1):ix(5,2))\(R(ix(4,1):ix(5,2),ix(1,1):ix(3,2))-O*X-A*R(ix(1,1):ix(1,2),ix(1,1):ix(3,2)));
  else
    e = R(ix(4,1):ix(5,2),ix(1,1):ix(3,2))-O*X-A*R(ix(1,1):ix(1,2),ix(1,1):ix(3,2));
  end
 
  f = N*trace(e*e');
 
  if nargout>1 then
    e = [R(ix(4,1):ix(4,2),ix(1,1):ix(3,2))-H*X-A(1:m,:)*R(ix(1,1):ix(1,2),ix(1,1):ix(3,2)),R(ix(4,1):ix(4,2),ix(4,1):ix(4,2))];
    KB = [pinv(O1)*R(ix(5,1):ix(5,2),ix(1,1):ix(4,2))/e;e*e'];
  end
  //
end
endfunction
