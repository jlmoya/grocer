function automatic_saturated_d()

global GROCERDIR ;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')

r=automatic('lm1-lp','lagts(lm1-lp)','lagts(2,lm1-lp)',...
'ly','lagts(ly)','lagts(2,ly)',...
'rnet','lagts(rnet)','lagts(2,rnet)',...
'delts(lp)','delts(lagts(lp))','delts(lagts(2,lp))',...
'const','trend^1','saturate')

endfunction
