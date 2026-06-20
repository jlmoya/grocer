function [rn]=nwest_d()
 
// PURPOSE: provides the Newey-West's adjusted heteroscedastic
// and autocorrelation consistent (HAC)estimation of the money
// equation # (6) in D.F Hendry et N.R Ericsson (1991):
// "Modeling the demand for narrow money in the United Kingdom
// and the United States", European Economic Review, p833-886,
// ------------------------------------------------------------
// INPUT:
// nothing
// ------------------------------------------------------------
// OUPTUT:
// * rn = the results tlist of the estimation
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols and save the results in the tlist
// rols; names are entered between quotes, in order that their
// names appears on the printed results
 
rn=nwest('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
endfunction
