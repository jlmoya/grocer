function small2=deleq_d()
    
global GROCERDIR
// load the model small
load(GROCERDIR+'data\small.dat')
small2=deleq(small,'tc_d5_s14e3','notransf') 
    
endfunction