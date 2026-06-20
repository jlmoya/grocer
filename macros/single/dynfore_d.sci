function [p]=dynfore_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat')
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols and save the results in the tlist
// rols; names are entered between quotes, in order that their
// names appears on the printed results
 
rols=ols('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
p=dynfore(rols,'lm1',['1985q1';'1988q4'])
 
pltseries('delts(lm1)','delts(p)','title=variation in log(UK M1)','leg=observed;simulated')
 
endfunction
