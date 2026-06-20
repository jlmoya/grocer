function [res1,res2] = li_mcleod_d()
 
// PURPOSE: demo of function li_mcleod
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat')
res1=li_mcleod('delts(lm1)',6)
 
disp('Press a key to see an example with the results of a varma estimation')	;
halt();
r=varma_d4()
res2=li_mcleod(r,10)
 
endfunction
