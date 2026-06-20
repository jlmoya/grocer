function [Phi,Gam,E,H,D,C,Q,S,R]=theta2sss(theta,thetalab,varargin)
 
// Returns the SS matrices from a simple model
// in E4 format.
// The SS formulation is:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    y(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// In models without exogenous variables Gam = [], D = [].
// In static models Phi = 0. If the perturbations are white
// noise E = 0.
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of parameters
// * thetalab = a string vector of instructions that transforms
//   theta into the matrices FR, FS, AR, AS, V and G
// ------------------------------------------------------------
// OUTPUT:
// * the matrices of the SS formulation
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[F,A,V,G] = theta2fr(theta,thetalab,varargin(:));
 
m=grocer_e4param.m
r=grocer_e4param.r
k=grocer_e4param.k
n=grocer_e4param.n
typ=grocer_e4param.typ
 
if typ < 3 then
  // W.N., VARMAX, ESTR
  F0 = F(1:m,1:m);
  A0 = A(1:m,1:m);
  Ab = zeros(n,m);
  Fb = zeros(n,m);
  for i = 1:k
    Fb((i-1)*m+1:i*m,:) = F(1:m,m*i+1:m*i+m);
    Ab((i-1)*m+1:i*m,:) = A(1:m,m*i+1:m*i+m);
  end
  if r then
    G0 = G(1:m,1:r);
    Gb = zeros(n,r);
    for i = 1:k
       Gb((i-1)*m+1:i*m,:) = G(1:m,r*i+1:r*i+r);
       Gb((i-1)*m+1:i*m,:) = G(1:m,r*i+1:r*i+r);
    end
  end
 
elseif typ==3 then
  // TF
  F0 = F(1);
  A0 = A(1);
  G0 = G(1:r);
  Fb = F(2:k+1)';
  Ab = A(2:k+1)';
  Gb = [];
  for i = 1:k
    Gb = [Gb;G(r*i+1:r*i+r)];
  end
 
else
 
   error('Incorrect model');
end
 
H = [eye(m,m),zeros(m,m*(k-1))];
C = A0;
 
if typ==0|k==0 then
 
  Phi = 0;
  E = zeros(1,m);
  H = H(:,1);
  Gam = zeros(1,r);
  D = G0;
 
else
  Phi = [-Fb,eye(m*k,m*(k-1))];
  E = Ab-Fb*A0;
  if r then
    Gam = Gb-Fb*G0;
    D = G0;
  else
    Gam = [];
    D = [];
  end
end
 
Q = V;
S = Q;
R = Q;
 
endfunction
