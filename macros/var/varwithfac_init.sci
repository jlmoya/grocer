function [Phi,H,Q,R,D]=varwithfac_init(p,y,z,AR,MA,Phi,H,Q,R,D,grocer_optfunc,grocer_opt_optim)
 
nbfac=length(AR)
nvar=size(y,2)

for i=1:nvar
   D(i,:)=ols0(y(:,i),z)'
end

resid=y-z*D'
rfac = fac_pca1(resid,1:nbfac,1,'no','no')
grocer_theta2ss=theta2sss
grocer_E4OPTION=sete4opt('vcond=lyap','var=fac','sca=y');
 
Phic0=0
for i=1:nbfac
   execstr('fac=rfac(''f'+string(i)+''')')
   ARi=vec2row(evstr(AR(i)))
   MAi=vec2row(evstr(MA(i)))
   narf=size(ARi,2)
   nmaf=size(MAi,2)
 
   [theta,x_T,P_T,ytT,theta2mat,grocer_e4param]=varma1(fac,ARi,[],MAi,[],1,1,%t,grocer_optfunc,grocer_opt_optim)
 
   [ARi,ARSi,MAi,MASi,Vi,Gi] = theta2arm2(theta,theta2mat);
 
   Phi(Phic0+1,Phic0+1:Phic0+narf)=string(-ARi)
   Phi(Phic0+1,Phic0+narf+1:Phic0+narf+nmaf)=string(MAi)
   H(:,Phic0+1)=string(rfac('loadings')(:,i)*2*sqrt(Vi))
 
   Phic0=Phic0+narf+nmaf
end
res=rfac('resid')'
 
n0=Phic0
nR=1
nresid=0
 
for i=1:nvar
   R(nR,nR)=string(sqrt(sum(res(:,i) .^ 2)/grocer_e4_T))
   nR=nR+1
end
 
endfunction
