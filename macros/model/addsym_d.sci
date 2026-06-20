function small2=addsym_d()
    
global GROCERDIR;
// load the model small:
load(GROCERDIR+'data\small.dat')
// load the database small_db:
small2=addsym(small,'endogenous','cb')
    
endfunction