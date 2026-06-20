function find_in_equations_d()
    
global GROCERDIR ; 
load(GROCERDIR+'\data\small.dat');// load the mesange model
// display all equations with the variable td_p3m_d1
find_in_equations(small,'td_p3m_d1')
    
endfunction