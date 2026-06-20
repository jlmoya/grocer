function [rolsc,rolsar1]=olsar1_d()
 
global GROCERDIR;
 
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// show the results of cochrane-Orcutt estimation
rolsc=olsc('delts(lm1-lp)','delts(lp)','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
// then show the result of olsar1
rolsar1=olsar1('delts(lm1-lp)','delts(lp)','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
endfunction
