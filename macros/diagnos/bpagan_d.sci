function []=bpagan_d()
 
// PURPOSE: an example using goldquandt
// ------------------------------------------------------------
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols and save the results in the tlist
// rols; names are entered between quotes, in order that their
// names appears on the printed results
 
rols=ols('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))'...
,'rnet','lagts(1,lm1-lp-ly)','cte')
 
// use golquandt to provides the heteroskedasticity test from
// the regression of the square of ols residuals on the
// exogenous variable and their square
 
bpagan(rols,'delts(lp)'...
,'delts(lagts(1,lm1-lp-ly))','rnet','lagts(1,lm1-lp-ly)','cte',...
'(delts(lp))^2','(delts(lagts(1,lm1-lp-ly)))^2'...
,'(rnet)^2','(lagts(1,lm1-lp-ly))^2')
 
// checks with hetero_sq0: should be the same !
[f,f_pvalue]=hetero_sq0(rols)
endfunction
