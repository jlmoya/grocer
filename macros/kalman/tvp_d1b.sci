function []=tvp_d1b()
 
global GROCERDIR ;

load(GROCERDIR+'/data/cousa.dat')
 
rols=ols('con','inc','cte')
b=rols('beta')
Q1=[298.145 -0.208469 ; -0.208469 0.000172402]
disp(Q1(1,2)^2/Q1(1,1)/Q1(2,2))
R= 72.8722
grocer_param=[sqrt(R) ; vech(Q1)]
  grocer_func='[Q,R]=tvp_param1a(grocer_param)'
grocer_priorb0=b
grocer_priorv0=100000*eye(2,2)
 
disp(-0.5*(filter_like(grocer_param,grocer_func,ts2vec(con),[ts2vec(inc) ones(39,1)],eye(2,2))+39*log(2*%pi)))
//r2=tvp('con','inc','cte','R=72.8722','Q=Q1','priorb0=b','priorv0=100000*eye(2,2)','tvpmeth=1a')
t2=timer();
endfunction
