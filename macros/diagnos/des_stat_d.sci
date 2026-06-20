function [r1,r2]=des_stat_d()
 
global GROCERDIR;
 
 
// demo of function des_stat
 
load(GROCERDIR+'/data/bdhenderic.dat') ; r=des_stat('delts(lm1)')
// open a new window: its number is the greatest number of all open window plus one
nw=max(winsid())+1
scf(nw)
// add a grey color
grey=addcolor([0.8 0.8 0.8]) ;
bounds('1964q1','1988q4');
r1=des_stat('delts(lm1)','nbars=10','color=grey','wind=nw')
 
endfunction
