function [r]=phil_perr_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
bounds('1964q1','1989q2')
r=phil_perr('lm1',0,15)
r=phil_perr('lm1',1)
endfunction
