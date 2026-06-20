function [flag,lambda,d,evec]=johansen_eigen_bortho(r0t,r1t,b,bortho,nbrel)
 
flag='OK'
nb=size(b,2)
r0_bt=r0t-r1t*b*ols0(r0t,r1t*b)
r1_bt=r1t-r1t*b*ols0(r1t,r1t*b)
borhtop_r1_bt=r1_bt*bortho
 
s11_b=borhtop_r1_bt'*borhtop_r1_bt/nobs
s00_b=r0_bt'*r0_bt/nobs
s10_borthop=borhtop_r1_bt'*r0t/nobs
 
sig = s10_borthop*inv(s00_b)*s10_borthop';
tmp = pinv(s11_b);
[au,du]=bdiag(tmp*sig,1/%eps)
[lambda,aind]=gsort(real(diag(au)),'g','d')
lambda=lambda(1:nbrel-nb)
 
if lambda(1) > 1 | lambda($) < 1E-8 then
   flag='not OK'
   return
end
 
dt = du*inv(chol(du'*s11_b*du));
d = bortho*dt(:,aind);
evec=[b d(:,1:nbrel-nb)]
 
endfunction
