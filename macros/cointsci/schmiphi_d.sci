function [r]=schmiphi_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
bounds('1964q1','1989q2')
r=schmiphi('lm1',1)
 
endfunction
