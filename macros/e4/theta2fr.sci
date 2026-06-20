function [F,A,V,G]=theta2fr(theta,thetalab,varargin)
 
// PURPOSE: Converts a THD model to reduced form of a simple model
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of parameters
// * thetalab = a string vetor of instructions that transforms
//   theta into the matrices FR, FS, AR, AS, V and G
// ------------------------------------------------------------
// OUTPUT:
// * F = the AR part of the model
// * A = the MA part of the model
// * G = the coefficients matrix for the endogenous variables
// * V = the (mxm) (var-covar) matrix
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
typ=grocer_e4param.typ
 
select typ
 
case 0
  [F,A,V,G] = theta2arma(theta,thetalab);
 
case 1
  [F,A,V,G] = theta2arma(theta,thetalab);
 
case 2 then
  [F,A,V,G] = thd2str(theta,thetalab);
  iF0 = inv(F(1:m,1:m));
  F = iF0*F;
  F(1:m,1:m) = eye(m,m);
  A = iF0*A;
  G = iF0*G;
 
case 3 then
  [F,A,V,W,D] = thd2tf(theta,thetalab);
  arp = F;
  // phi(B)*PHI(B)*d1(B)*...*dr(B)
  for i = 1:r
    F = convol(F,D(i,:));
    A = convol(A,D(i,:));
  end
  // wbi(B) = phi(B)*PHI(B)*wi(B)*dj(B) for all j <> i
  wp = zeros(r,n+1);
  for i = 1:r
    wpd = convol(arp,W(i,:));
    for j = 1:r
      if i~=j then
        wpd = convol(wpd,D(j,:));
      end
    end
    wp(i,1:min(size(wpd,2),n+1)) = wpd(1:min(size(wpd,2),n+1));
  end
  G = wp(:)';
  A = [A(1:min(size(A,2),n+1)),zeros(1,n-size(A,2)+1)];
  F = [F(1:min(size(F,2),n+1)),zeros(1,n-size(F,2)+1)];
 
case 4 then
  [F,A,V,G] = thd2ech(theta,thetalab);
  iF0 = inv(F(1:m,1:m));
  F = iF0*F;
  F(1:m,1:m) = eye(m,m);
  A = iF0*A;
  A(1:m,1:m) = eye(m,m);
  G = iF0*G;
 
else
  error('Incorrect model');
end
 
endfunction
