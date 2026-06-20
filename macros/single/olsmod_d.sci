function olsmod_d()
    
load(GROCERDIR+'\data\small.dat')
load(GROCERDIR+'\data\small_db.dat')
bounds('1990q1','2005q4')
olsmod(small,small_db,'td_p3m_d1')

endfunction
