function [Phi,Gam,E,H,D,C,Q,S,R]=theta2ss(theta,thetalab,varargin)
 
// Returns the SS matrices from model in E4 format
// The SS formulation is:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    y(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// In composite models or models without exogenous variables
// Gam = [], D = [].
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of parameters
// * thetalab = a string vetor of instructions that transforms
//   theta into the matrices FR, FS, AR, AS, V and G
// ------------------------------------------------------------
// OUTPUT:
// * the matrices of the SS formulation
// ------------------------------------------------------------
// NOTE:
// This function is designed in E4 package to work with
// all models, but for the time beign, works only with VARMAx
// models
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
if grocer_e4_userflag then
// user provided function
  [Phi,Gam,E,H,D,C,Q,S,R] = theta2own(theta,thetalab);
 
elseif grocer_e4param.typ < 4 then
  // simple model
  [Phi,Gam,E,H,D,C,Q,S,R] = theta2sss(theta,thetalab,varargin(:));
 
elseif grocer_e4param.typ==4 then
  // echelon
  [Phi,Gam,E,H,D,C,Q,S,R] = thd2ssh(theta,thetalab);
 
elseif grocer_e4param.typ==7 then
  [Phi,Gam,E,H,D,C,Q,S,R] = theta2ssss(theta,thetalab,grocer_E4OPTION('var'));
 
elseif fix(grocer_e4param.typ/10)==2 then
  // nested
  [Phi,Gam,E,H,D,C,Q,S,R] = thd2ssn(theta,thetalab);
 
elseif fix(grocer_e4param.typ/10)==3 then
  // components
  [Phi,Gam,E,H,D,C,Q,S,R] = thd2ssc(theta,thetalab);
 
else
   error('Incorrect model');
end
 
endfunction
