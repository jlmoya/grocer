function [y] = simmod(theta,theta2mat,n,u)
 
// SIMMOD   - Simulates a model in THD representation.
//    y = simmod(theta, din, N, u, userf)
// theta > parameter vector.
// din   > matrix which stores a description of the model dynamics.
// N     > number of observations of the simulated series.
// u     > input series (only if the model includes inputs).
// userf > user function (only for user models).
// y     < simulated series.
// This function uses MATLAB''s random number generators.
//
//  7/3/97
//  Copyright (c) Jaime Terceiro, 1997
 
econd = grocer_E4OPTION('econd')
[nargout,nargin]=argn(0)
 
[Phi,Gam,E,H,D,C,Q,S,R] = theta2ss(theta,theta2mat);
l = size(Phi,1);
m = size(H,1);
r=max([size(Gam,2), size(D,2)]);
if r then
   if nargin<4 then
      error('you should have entered exogenous variables');
   end;
   if or(size(u) ~= [n,r]) then
      error('size of exogenous variables should be: (' +string(n)+','+string(r) )
   ;end;
end;
 
[U,S,U] = svd([Q S;S' R]);
 
sq = size(Q,1);
sr = size(R,1)+sq;
 
a = grand(n,sr,'nor',0,1);
a = (U*sqrt(S))*a';
 
y = zeros(n,m);
 
if r & or(econd == ['umean','u0']) then
  //
  if econd == 'umean' then
    u0 = mean0(u,"r")';
  else
    u0 = u(1,:)'
  end;
 
  [x, P0] =  djccl(Phi, E*Q*E', 0, Gam*u0);
  //
else
  [x, P0] =  djccl(Phi, E*Q*E', 0,[]);
end;
 
[U,S,U] = svd(P0);
x = x + U * sqrt(S)*grand(l,1,'nor',0,1);
 
if r then
   for i = 1:n // main loop
  //
      y(i,:) = (H*x + D*u(i,:)' + C*a(sq+1:sr,i))';
      x = Phi * x + Gam * u(i,:)' + E*a(1:sq,i);
   end
 
else
   for i = 1:n // main loop
  //
      y(i,:) = (H*x + C*a(sq+1:sr,i))';
      x = Phi * x + E*a(1:sq,i);
   end
end
 
endfunction
