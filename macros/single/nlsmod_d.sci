function nlsmod_d()
    
load(GROCERDIR+'\data\small.dat')
load(GROCERDIR+'\data\small_db.dat')
bounds('1981q1','2005q4');
// In the small model, estimate by non-linear least squares the equation td_p6_d1
// Estimated coefficients are stored into the small model tlist and
// the whole estimation results are stored into tlist rp6_d1:
nlsmod(small,small_db,'td_p6_d1','save=%t')

endfunction
