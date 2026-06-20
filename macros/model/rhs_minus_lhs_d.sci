function rhs_minus_lhs_d()

global GROCERDIR;
// load the model small:
load(GROCERDIR+'data\small.dat')
// load the database small_cale
load(GROCERDIR+'data\small_cale.dat')
small_cale_db=small_cale('simulation results');
rhs_minus_lhs(small,small_cale_db,['1981q1';'2006q4'],1e-10)    

endfunction