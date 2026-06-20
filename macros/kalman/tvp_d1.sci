function [r1]=tvp_d1()
 
global GROCERDIR ;
 
load(GROCERDIR+'/data/cousa.dat')
 
bounds();
rols=ols('con/10000','inc/10000','cte')
b=rols('beta')
sigu=sqrt(rols('sigu'))
write(%io(2),'like ols:','(a)')
disp(rols('llike'))
timer();
r1=tvp('con/10000','inc/10000','cte','R=sigu','Q=0.0001*eye(2,2)','priorb0=b','priorv0=1000*eye(2,2)','tvpmeth=1')
 
Q1=r1('Q')
R1=r1('R')
nobs=r1('nobs')
betat=r1('betat')
betat1=betat(2:nobs,1)-betat(1:nobs-1,1)
betat2=betat(2:nobs,2)-betat(1:nobs-1,2)
c=betat1'*betat2/r1('nobs')
 
r2=tvp('con/10000','inc/10000','cte','R=R1','Q=Q1','priorb0=b','priorv0=10000*eye(2,2)','tvpmeth=1a')
 
endfunction
