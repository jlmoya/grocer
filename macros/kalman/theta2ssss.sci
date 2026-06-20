function [Phi,Gam,E,H,D,C,Q,S,R]=theta2ssss(theta,theta2mat,factorized)
 
Phi=grocer_e4param.Phi
Gam=grocer_e4param.Gam
E=grocer_e4param.E
H=grocer_e4param.H
D=grocer_e4param.D
C=grocer_e4param.C
Q=grocer_e4param.Q
S=grocer_e4param.S
R=grocer_e4param.R
 
execstr(theta2mat)
 
if grocer_e4param.innov then
// R = S = Q
   R = Q;
   S = Q
   if factorized =='factorized' then
      S = Q*Q';
   end
end
 
if factorized == 'factorized' then
   Q = Q*Q';
   R = R*R';
end
 
endfunction
 
