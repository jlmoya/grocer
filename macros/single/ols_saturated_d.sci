function ols_saturated_d()

global GROCERDIR
load(GROCERDIR+'/data/bdhenderic.dat') ;
bounds('1964q3','1989q2')
r=ols('lm1-lp','ly','delts(lp)','rnet','lagts(lm1-lp)','lagts(2,lm1-lp)','lagts(rnet)','saturate(0.01)')


endfunction
