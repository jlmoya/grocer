function [F,dF,A,dA,V,dV,G,dG]=arma_dv(theta,theta2mat,di)
 
// PURPOSE: Computes the partial derivatives of the matrices
// in reduced form of a VARMAX model with respect to i-th
// parameter of the theta vector.
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * di = a scalar
// ------------------------------------------------------------
// OUTPUT:
// * F = the whole AR part of the model
// * A = the whole MA part of the model
// * V = the variance of the residuals
// * G = the coefficients of the exogenous variables
// * dF, dA, dV, dG = the derivatives of these matrices with
// respect to the i-th parameter in theta
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
if di<1|di>size(theta,1) then
  error('i inconsistent with THETA (out of range)');
end
 
[FR,FS,AR,AS,V,G0] = theta2arm2(theta,theta2mat,1);
dtheta = zeros(size(theta,1),1);
dtheta(di) = 1
[dFR,dFS,dAR,dAS,dV,dG0] = theta2arm2(dtheta,theta2mat,1);
 
s=grocer_e4param.s
m=grocer_e4param.m
k=grocer_e4param.k
g=grocer_e4param.g
r=grocer_e4param.r
 
F = eye(m,(1+k)*m);
A = eye(m,(1+k)*m);
G = zeros(m,(1+k)*r);
dF = zeros(m,(1+k)*m);
dA = zeros(m,(1+k)*m);
dG = zeros(m,(1+k)*r);
 
if r then
  G(:,1:r*g) = G0;
  dG(:,1:r*g) = dG0;
end
 
F(:,m+1:m*(grocer_e4param.p+1)) = FR;
dF(:,m+1:m*(grocer_e4param.p+1)) = dFR;
for i = 1:grocer_e4param.P
   F(:,i*s*m+1:(i*s+1)*m) = ...
     F(:,i*s*m+1:(i*s+1)*m)+FS(:,(i-1)*m+1:i*m);
   dF(:,i*s*m+1:(i*s+1)*m) = ...
     dF(:,i*s*m+1:(i*s+1)*m)+dFS(:,(i-1)*m+1:i*m);
 
  for j = 1:grocer_e4param.p
    F(:,(i*s+j)*m+1:(i*s+j+1)*m) = ...
      F(:,(i*s+j)*m+1:(i*s+j+1)*m)+...
      FR(:,(j-1)*m+1:j*m)*FS(:,(i-1)*m+1:i*m);
    dF(:,(i*s+j)*m+1:(i*s+j+1)*m) = ...
      dF(:,(i*s+j)*m+1:(i*s+j+1)*m)+...
      dFR(:,(j-1)*m+1:j*m)*FS(:,(i-1)*m+1:i*m)+...
      FR(:,(j-1)*m+1:j*m)*dFS(:,(i-1)*m+1:i*m);
  end
end
 
A(:,m+1:m*(grocer_e4param.q+1)) = AR;
dA(:,m+1:m*(grocer_e4param.q+1)) = dAR;
for i = 1:grocer_e4param.Q
  A(:,i*s*m+1:(i*s+1)*m) = ...
  A(:,i*s*m+1:(i*s+1)*m)+AS(:,(i-1)*m+1:i*m);
  dA(:,i*s*m+1:(i*s+1)*m) = ...
  dA(:,i*s*m+1:(i*s+1)*m)+dAS(:,(i-1)*m+1:i*m);
  for j = 1:grocer_e4param.q
    A(:,(i*s+j)*m+1:(i*s+j+1)*m) = ...
      A(:,(i*s+j)*m+1:(i*s+j+1)*m)+...
      AR(:,(j-1)*m+1:j*m)*AS(:,(i-1)*m+1:i*m);
    dA(:,(i*s+j)*m+1:(i*s+j+1)*m) = ...
      dA(:,(i*s+j)*m+1:(i*s+j+1)*m)+...
      dAR(:,(j-1)*m+1:j*m)*AS(:,(i-1)*m+1:i*m)+...
      AR(:,(j-1)*m+1:j*m)*dAS(:,(i-1)*m+1:i*m);
  end
end
 
if grocer_E4OPTION('var') == 'unfactorized' then
  if min(spec(V))<=0 then
    Vu = cholp(V);
    V = Vu'*Vu;
  end
else
  dV = dV*V'+V*dV';
  V = V*V';
end
 
endfunction
 
