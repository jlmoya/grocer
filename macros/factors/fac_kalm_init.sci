function [Phi,H,Q,R]=fac_kalm_init(y,AR,MA,Phi,H,Q,R,listar)


opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',sqrt(%eps),100',1e-5)
 
nbfac=length(AR)
 
nargin=length(listar)
rfac = fac_pca1(y,1:nbfac,1,'no','no')
grocer_theta2ss=theta2sss
grocer_E4OPTION=sete4opt('vcond=lyap','var=fac','sca=y');
 
Phic0=0
for i=1:nbfac
   execstr('fac=rfac(''f'+string(i)+''')')
   ARi=vec2row(evstr(AR(i)))
   MAi=vec2row(evstr(MA(i)))
   narf=size(ARi,2)
   nmaf=size(MAi,2)
 
   [theta,x_T,P_T,ytT,theta2mat,grocer_e4param]=varma1(fac,ARi,[],MAi,[],1,1,%t,'optimg',opt_optim)
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
 
for i=1:nargin
   nari=size(listar(i),'*')
   n1=n0+nari
   if nari ~= 0 then
      nresid=nresid+(nari ~= 0)
      resi=res(:,i)
      lagresi=lag(resi,1:nari)
      b0=ols0(resi,lagresi)
      Phi(n0+1,n0+1:n1)=string(b0')
      Q(1+nresid,nresid+1)=string(sqrt(sum((resi-lagresi*b0).^2)/grocer_e4_T))
   else
      R(nR,nR)=string(sqrt(sum(res(:,i) .^ 2)/grocer_e4_T))
      nR=nR+1
   end
   n0=n1
end
 
endfunction
