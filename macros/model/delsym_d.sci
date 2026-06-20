function small2=delsym_d()
    
global GROCERDIR
// load the model small
load(GROCERDIR+'data\small.dat')
// in model small, change to exoegnous the statute of variable tc_d5_s14e3:
small2=delsym(small,'exogenous','tc_d5_s14e3')
    
endfunction