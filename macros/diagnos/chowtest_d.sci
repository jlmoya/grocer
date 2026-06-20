function [r]=chowtest_d()
 
global GROCERDIR;
 
// provided an example for the function chowtest()
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
bounds('1964q3','1989q2')
 
// column HE in table 9 of Hendry and Krozlig paper
r=ols('delts(lm1-lp)','lagts(lm1-lp-ly)','delts(lp)','rnet','delts(lagts(lm1-lp-ly))','cte')
 
chowtest(r,50)
 
 
 
endfunction
