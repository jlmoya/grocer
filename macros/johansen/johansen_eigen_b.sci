function [flag,rho,r0t,r1t]=johansen_eigen_b(dy,exo,lagy,b)
 
flag='OK'
nb=size(b,2)
r0t = dy-exo*ols0(dy,exo)
r1t = lagy-exo*ols0(lagy,exo)
s00 = r0t'*r0t/nobs
s11 = r1t'*r1t/nobs
s10 = r1t'*r0t/nobs
 
sig = s10'*b*inv(b'*s11*b)*b'*s10;
tmp = pinv(s00);
[au,du]=bdiag(tmp*sig,1/%eps)
[rho,aind]=gsort(diag(au),'g','d')
rho=real(rho(1:nb))
 
if rho(1) > 1 | rho($) < 1E-8 then
   flag='not OK'
end
 
endfunction
 
