function [flag,logL_new,beta1,beta2]=johansen_iter_beta_part(r0t,r1t,s00,s11,s10,H1,beta1,nitermax,crit)
 
[nrowH1,ncolH1]=size(H1)
dllike=1
logL_old=-%inf
flag='OK'
niter=0
 
while niter <= nitermax & dllike > crit & flag == 'OK'
   niter=niter+1
 
   rho2= real(beta1'*s10*inv(s00)*s10'*beta1/(beta1'*s11*beta1))
 
   r0_bt=r0t-r1t*beta1*ols0(r0t,r1t*beta1)
   r1_bt=r1t-r1t*beta1*ols0(r1t,r1t*beta1)
 
   s11_b=r1_bt'*r1_bt/nobs
   s00_b=r0_bt'*r0_bt/nobs
   s10_b=r1_bt'*r0_bt/nobs
 
   [lambda2,beta2]=canonical_singular(s11_b,s10_b,s00_b,nrowH1-1,nbrel-1)
   if or([lambda2(1) rho2]>1) then
      flag='not OK'
   else
      logL_new=-0.5*nobs*(sum(log(1-lambda2(1:nbrel-1)))+log(1-rho2))
 
      r0_bt=r0t-r1t*beta2*ols0(r0t,r1t*beta2)
      r1_t_H1=r1t*H1
      r1_bt=r1_t_H1-r1t*beta2*ols0(r1_t_H1,r1t*beta2)
 
      s11_b=r1_bt'*r1_bt/nobs
      s00_b=r0_bt'*r0_bt/nobs
      s10_b=r1_bt'*r0_bt/nobs
 
      sig = s10_b*inv(s00_b)*s10_b';
      tmp = pinv(s11_b);
      [du,au]=spec(tmp*sig)
      [lambda1,aind]=gsort(real(diag(au)),'g','d')
      if lambda1(1) > 1 | lambda1($) < 1e-10 then
         flag='not OK'
      else
         dt = du*inv(chol(du'*s11_b*du));
         d = real(dt(:,aind));
         beta1=H1*d(:,1)
         dllike=logL_new-logL_old
         logL_old=logL_new
      end
   end
end
 
 
endfunction
 
