function [rarma,rarmf]=varmaf_d()
 
global GROCERDIR;
 
// provide an example for the use of the varmaf function
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
bounds('1964q3','1988q4')
// estimates the arma model
rarma=varma('rnet',[0 0],[],[0],[],0,1,'exo=''const''','Gexo=1')
// performs a forecats starting from after the estimation period
rarmf=varmaf(rarma,['1989q3' ; '1990q4'])
 
endfunction
 
