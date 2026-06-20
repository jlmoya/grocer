function [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR]=ss_dv(theta,theta2mat,i,varargin)
 
// PURPOSE: Computes the partial derivatives of the matrices of
// a SS model with respect to the i-th parameter in theta.
// The model is suppose to be written as follows:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    y(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * i = a scalar
// ------------------------------------------------------------
// OUTPUT:
// dPhi, dGam, dE, dH,dD,dC,dQ,dS,dR = the derivatives of the
// corresponding matrices (that is unprefixed by d) with
// respect to the i-th parameter in theta.
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
if grocer_e4_userflag then
  if grocer_e4_userflag<2 then
    error('User function not defined for the analytic gradient');
  end
  [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvown(theta,theta2mat,i,userf(2,:));
  return
 
end
 
typ=grocer_e4param.typ
if typ < 4 then
   // simple model
   [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvs(theta,theta2mat,i);
elseif typ == 4 then
   // echelon
   [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvh(theta,theta2mat,i);
 
elseif typ == 7 then
   [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvss(theta,theta2mat,i);
 
elseif fix(typ/10) == 2 then
   // nested
   [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvn(theta,theta2mat,i);
 
elseif fix(typ/10) == 3 then
   // components
   [dPhi,dGam,dE,dH,dD,dC,dQ,dS,dR] = ss_dvc(theta,theta2mat,i);
end
 
endfunction
