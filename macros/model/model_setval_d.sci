function small=model_setval_d()
    
global GROCERDIR ; 
load(GROCERDIR+'\data\small.dat');// load the mesange model
// display all equations with the variable td_p3m_d1
// set to 0.6 the value of the parameter p1d5s14 in model small:
small=model_setval(small,'p1d5s14',0.6)
    
endfunction