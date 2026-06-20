function [AR,ARS,MA,MAS,V,G]=theta2arm2(theta,theta2mat,fromgrad)
 
// PURPOSE: recovers the matrices of an ARMA process from the
// values of the estimated parameters
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of parameters
// * theta2mat = a string vetor of instructions that transforms
//   theta into the matrices FR, FS, AR, AS, V and G
// * fromgrad = if not given, forces the matrix V to be
//   positive definite
// ------------------------------------------------------------
// OUPTUT:
// FR,FS,AR,AS,V,G = matrices of the process:
// (I + FR1·B +...+FRp·B^p)(I + FS1·B^s +...+ FSps·B^ps·s) y(t)
// = (G0 + G1·B +...+ Gt·B^l) u(t) +
// (I + AR1·B +...+ARq·B^q)(I + AS1·B^s +...+ ASqs·B^qs·s) a(t)
//
// with Var(a(t)) = V
// ------------------------------------------------------------
// Copyright: Jaime Terceiro, 1997/
// Eric Dubois 2003 for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
// gets the matrices in the function in order to transform them
// through theta2mat
AR=grocer_e4param.AR
ARS=grocer_e4param.ARS
MA=grocer_e4param.MA
MAS=grocer_e4param.MAS
V=grocer_e4param.V
G=grocer_e4param.G
 
execstr(theta2mat)
// Force V positive definite
if nargin<3 then
  if grocer_E4OPTION('var') == 'unfactorized' then
    if min(spec(V))<=0 then
      Vu = cholp(V);
      V = Vu'*Vu;
    end
  else
    V = V*V';
  end
end
 
endfunction
 
