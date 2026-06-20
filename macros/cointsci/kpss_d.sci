function []=kpss_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
bounds('1964q1','1989q2')
kpss('lm1',0)
kpss('lm1',1)
 
endfunction
