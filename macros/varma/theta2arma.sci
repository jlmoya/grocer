function [F,A,V,G]=theta2arma(theta,theta2mat,varargin)
 
// PURPOSE: Converts a VARMA model to reduced form VARMAX notation.
// The input arguments corresponding to the model:
//   (I + AR1·B + ... +ARp·B^p)(I + ARS1·B^s + ... + ARSps·B^ps·s) y(t) =
//   (G0 + G1·B + ... + Gt·B^l) u(t) +
//   (I + MA1·B + ... + MAq·B^q)(I + MAS1·B^s + ... + MASqs·B^qs·s) a(t)
// are transformed to
//   F(B)y(t) = G(B)u(t) + A(B)e(t)
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of parameters
// * theta2mat = a string vetor of instructions that transforms
//   theta into the matrices AR, ARS, MA, MAS, V and G
// ------------------------------------------------------------
// OUTPUT:
// * F = the AR part of the model
// * A = the MA part of the model
// * G = the coefficients matrix for the endogenous variables
// * V = the (mxm) (var-covar) matrix
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997
// Eric Dubois 2003 for the Scilab translation and adpatation
// http://grocer.toolbox.free.fr/grocer.html
 
[AR,ARS,MA,MAS,V,G0] = theta2arm2(theta,theta2mat,varargin(:));
 
m=grocer_e4param.m
k=grocer_e4param.k
s=grocer_e4param.s
r=grocer_e4param.r
q=grocer_e4param.q
 
F = eye(m,(1+k)*m);
A = eye(m,(1+k)*m);
G = zeros(m,(1+k)*r);
G(:,1:r*(grocer_e4param.g)) = G0;
F(:,m+1:m*(grocer_e4param.p+1)) = AR;
for i = 1:grocer_e4param.P
  i1=i*s*m+1:(i*s+1)*m
  i2=(i-1)*m+1:i*m
  F(:,i1) = F(:,i1)+ARS(:,i2);
  for j = 1:grocer_e4param.p
    j1=(i*s+j)*m+1:(i*s+j+1)*m
    F(:,j1) = F(:,j1)+ AR(:,(j-1)*m+1:j*m)*ARS(:,i2);
  end
end
 
A(:,m+1:m*(q+1)) = MA;
for i = 1:grocer_e4param.Q
  i1=i*s*m+1:(i*s+1)*m
  i2=(i-1)*m+1:i*m
  A(:,i1) = A(:,i1)+MAS(:,i2);
  for j = 1:grocer_e4param.q
    j1=(i*s+j)*m+1:(i*s+j+1)*m
    A(:,j1) = A(:,j1) + MA(:,(j-1)*m+1:j*m)*MAS(:,i2);
  end
end
 
endfunction
 
