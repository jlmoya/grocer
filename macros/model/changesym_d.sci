function small2=changesym_d()
    
global GROCERDIR;
// load the model small:
load(GROCERDIR+'data\small.dat')
small2=changesym(small,'exogenous','tc_d5_s14e3')
 
    
endfunction