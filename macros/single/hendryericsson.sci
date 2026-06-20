function [rols]=hendryericsson()
 
// PURPOSE: provides the estimation of the money equation # (6)
// in D.F Hendry et N.R Ericsson (1991): "Modeling the demand
// for narrow money in the United Kingdom and the United
// States", European Economic Review, p833-886.
// ------------------------------------------------------------
// INPUT:
// nothing
// ------------------------------------------------------------
// OUPTUT:
// * rols = the results tlist of the ordianry least squares
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols and save the results in the tlist
// rols; names are entered between quotes, in order that their
// names appears on the printed results
 
rols=olspec('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
// provides the Jarque and Bera and Doornik and Hansen normality
// tests
jbnorm(rols)
 
// White's test (called XiXj in Hendry-Ericsson)
white(rols)
 
// provides the heteroskedasticity test from the regression of
// the square of ols residuals on the exogenous variable and
// their square
hetero_sq(rols)
 
// provides the ARCH test with 4 lags
rarch=archz(rols,4)
 
 
// provides Ramsay RESET test with power 2
reset(rols,2)
endfunction
