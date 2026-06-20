function [r]=tvp_d1c()
 
global GROCERDIR ;

load(GROCERDIR+'/data/lutk1.dat')
r=tvp('delts(log(rfa_cons))','cte','delts(log(rfa_inc))','delts(log(lagts(rfa_inc)))',...
'delts(log(lagts(rfa_cons)))','delts(log(lagts(2,rfa_inc)))',...
'delts(log(lagts(2,rfa_cons)))','optmeth=optim')
endfunction
