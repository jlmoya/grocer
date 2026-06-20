function ladmod_d()
    
load(GROCERDIR+'\data\small.dat')
load(GROCERDIR+'\data\small_db.dat')
bounds('1981q1','2005q4')
ladmod(small,small_db,'tc_d11_d5')

endfunction
