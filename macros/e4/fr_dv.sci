function [F,dF,A,dA,V,dV,G,dG]=fr_dv(theta,theta2mat,di)
 
// PURPOSE: Computes the partial derivatives of the reduced
// form matrices of any simple model with respect to the i-th
// parameter in theta. Also return the reduced form of the
// model.
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
 
typ=grocer_e4param.typ
 
m=grocer_e4param.m
 
if typ == 0|typ == 1 then
  [F,dF,A,dA,V,dV,G,dG] = arma_dv(theta,theta2mat,di);
elseif typ == 2 then
  [F,dF,A,dA,V,dV,G,dG] = str_dv(theta,theta2mat,di);
  iF0 = inv(F(1:m,1:m));
  dF0 = dF(1:m,1:m);
  diF0 = -iF0*dF0*iF0;
  F = iF0*F;
  F(1:m,1:m) = eye(m,m);
  dF = diF0*F+iF0*dF;
  A = iF0*A;
  dA = diF0*A+iF0*dA;
  G = iF0*G;
  dG = diF0*G+iF0*dG;
elseif typ ==3 then
  [F,dF,A,dA,V,dV,W,dW,D,dD] = tf_dv(theta,theta2mat,di);
  arp = F;
  darp = dF;
  for i = 1:grocer_e4_r
    dF = convol(dF,D(i,:))+convol(F,dD(i,:));
    dA = convol(dA,D(i,:))+convol(A,dD(i,:));
    F = convol(F,D(i,:));
    A = convol(A,D(i,:));
  end
  wp = zeros(r,grocer_e4_n+1);
  dwp = zeros(r,grocer_e4_n+1);
  for i = 1:grocer_e4_r
    wpd = convol(arp,W(i,:));
    dwpd = convol(arp,dW(i,:))+convol(darp,W(i,:));
    for j = 1:grocer_e4_r
      if i~=j then
        dwpd = convol(wpd,dD(j,:))+convol(dwpd,D(j,:));
        wpd = convol(wpd,D(j,:));
      end
    end
    dwp(i,1:min(size(dwpd,2),grocer_e4_n+1)) = dwpd(1:min(size(dwpd,2),grocer_e4_n+1));
    wp(i,1:min(size(wpd,2),grocer_e4_n+1)) = wpd(1:min(size(wpd,2),grocer_e4_n+1));
  end
 
  G = wp(:)';
  dG = dwp(:)';
 
  A = [A(1:min(size(A,2),grocer_e4_n+1)),zeros(1,grocer_e4_n-size(A,2)+1)];
  F = [F(1:min(size(F,2),grocer_e4_n+1)),zeros(1,n-size(F,2)+1)];
  dA = [dA(1:min(size(dA,2),grocer_e4_n+1)),zeros(1,grocer_e4_n-size(dA,2)+1)];
  dF = [dF(1:min(size(dF,2),grocer_e4_n+1)),zeros(1,grocer_e4_n-size(dF,2)+1)];
else
  error('Incorrect model');
end
endfunction
