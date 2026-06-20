function [r1,r2]=adf_d()
 
global GROCERDIR;
 
bounds()
load(GROCERDIR+'/data/cousa.dat')
r1=adf('log(inc)',1,4)
r2=adf('log(inc)',0,4)
endfunction
