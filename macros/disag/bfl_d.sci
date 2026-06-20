function [y,res]=bfl_d()
 
global GROCERDIR;
 
load(GROCERDIR+'\data\xesp.dat')
 
[y,res] = bfl(Y,0,1,12);
endfunction
