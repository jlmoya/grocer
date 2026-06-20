function ivmod_d()
    
load(GROCERDIR+'\data\small.dat')
load(GROCERDIR+'\data\small_db.dat')
bounds('1980q1','2005q4')
ivmod(small,small_db,'td_p523_d1','delts(1,td_dint_dhs1)',['delts(demmon)','const'],'save=%t')

endfunction
