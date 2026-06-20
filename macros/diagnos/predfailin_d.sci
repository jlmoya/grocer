function [r]=predfailin_d()
 
global GROCERDIR;
 
// provide an example for the function predfail()
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
bounds('1964q3','1989q2')
cte=reshape(ones(104,1)','1964q1')
// column HE in table 9 of Hendry and Krozlig paper
r=ols('delts(lm1-lp)','lagts(lm1-lp-ly)','delts(lp)','rnet','delts(lagts(lm1-lp-ly))','cte')
 
predfailin(r,50)
 
endfunction
