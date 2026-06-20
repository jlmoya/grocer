function [rwhite]=hwhite_d()
 
// PURPOSE: provides the estimation of the money equation #
// in
// ------------------------------------------------------------
// INPUT:
// nothing
// ------------------------------------------------------------
// OUPTUT:
// * rols = the results tlist of the ordinary least squares
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols
 
ols('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
// estimate the model by ols
rwhite=hwhite('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
endfunction
