function [res1,res2] = ljungbox_d()
 
// PURPOSE: demo of function ljungbox
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat')
res1=ljungbox('delts(lm1)',6)
 
write(%io(2),'Press a key to see an example with the results of a varma estimation','(a)')	;
halt();
r=varma_d4()
res2=ljungbox(r,10)
 
endfunction
