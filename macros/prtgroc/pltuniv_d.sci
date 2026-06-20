function [rols]=pltuniv_d()
 
// PURPOSE: an example using pltuniv()
// with the estimation of the money equation # (6)
// in D.F Hednry et N.R Ericsson (1991): "Modeling the demand
// for narrow money in the United Kingdom and the United
// States", European Economic Review, p833-886.
 
 
 
 
load('grocer/bdexamples/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols and save the results in the tlist
// rols; names are entered between quotes, in order that their
// names appears on the printed results
 
rols=ols('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte','noprint')
 
pltuniv(rols,'all')
// N.B is equivalent to pltuniv(rols,)
endfunction
