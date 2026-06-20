function [f,NB]=e4prees2(theta,theta2mat,R,ix,ij)
 
// PURPOSE: Provides a quick estimation of the parameters of a
// model using a subspace representation model where the
// future of the output is expressed as a linear function of
// its past and the information in the input
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * z = matrix of endogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * f = (npx1) vector of estimated parameters
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
[Phi,Gam,E,H,D,C,Q] = grocer_theta2ss(theta,theta2mat);
 
n = size(Phi,1);
m = size(H,1);
r = max([size(Gam,2),size(D,2)]);
 
iC = pinv(C);
E = E*iC;
 
i = ij(1);
j = ij(2);
pond = ij(3);
N = ij(4);
 
O = [H;zeros((j-1)*m,n)];
 
Phi2 = Phi;
 
for k = 1:j-1
  O(k*m+1:(k+1)*m,:) = H*Phi2;
  Phi2 = Phi2*Phi;
end
 
iO = pinv(O);
O1 = O(1:(j-1)*m,:);
 
if ~r then
  //
  X = [iO*R(ix(2,1):ix(3,2),ix(1,1):ix(1,2)),zeros(n,m)];
  if pond then
    e = R(ix(3,1):ix(3,2),ix(3,1):ix(3,2))\(R(ix(3,1):ix(3,2),ix(1,1):ix(2,2))-O1*((Phi-E*H)*X+E*R(ix(2,1):ix(2,2),ix(1,1):ix(2,2))));
  else
    e = R(ix(3,1):ix(3,2),ix(1,1):ix(2,2))-O1*((Phi-E*H)*X+E*R(ix(2,1):ix(2,2),ix(1,1):ix(2,2)));
  end
 
  f = N*real(trace(e*e'));
 
  if nargout>1 then
    e = R(ix(2,1):ix(2,2),ix(1,1):ix(2,2))-H*X;
    NB = iC*e*e'*iC';
  end
  //
else
  //
  Hid = [[D;O1*Gam],zeros(j*m,(j-1)*r)];
  for k = 2:j
    Hid((k-1)*m+1:j*m,(k-1)*r+1:k*r) = Hid(1:(j-k+1)*m,1:r);
  end
 
  A = (eye(j*m,i*m)-O*iO)*Hid;
  Di = A(1:m,:);
  Gami = A(m+1:m*j,:);
 
  X = [iO*R(ix(4,1):ix(5,2),ix(1,1):ix(3,2)),zeros(n,m)];
  if pond then
    e = R(ix(5,1):ix(5,2),ix(5,1):ix(5,2))\(R(ix(5,1):ix(5,2),ix(1,1):ix(4,2))-O1*((Phi-E*H)*X+E*R(ix(4,1):ix(4,2),ix(1,1):ix(4,2)))-(Gami-O1*E*Di)*R(ix(1,1):ix(1,2),ix(1,1):ix(4,2)));
  else
    e = R(ix(5,1):ix(5,2),ix(1,1):ix(4,2))-O1*((Phi-E*H)*X+E*R(ix(4,1):ix(4,2),ix(1,1):ix(4,2)))-(Gami-O1*E*Di)*R(ix(1,1):ix(1,2),ix(1,1):ix(4,2));
  end
  f = N*trace(e*e');
 
  if nargout>1 then
    e = R(ix(4,1):ix(4,2),ix(1,1):ix(4,2))-H*X-Di*R(ix(1,1):ix(1,2),ix(1,1):ix(4,2));
    NB = iC*e*e'*iC';
  end
  //
end
endfunction
