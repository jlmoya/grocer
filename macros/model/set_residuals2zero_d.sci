function small_dbnew=set_residuals2zero_d()

global GROCERDIR;
// load the model small:
load(GROCERDIR+'data\small.dat')
// load the simulation results small_cale
load(GROCERDIR+'data\small_cale.dat')
small_cale_db=small_cale('simulation results')
// display the value of the residual p3m_d5_cale:
prt_tsmat('level',['1990q1';'2006q4'],list('small_cale_db'),'p3m_d5_cale')
// set residuals of database small_cale_db to 0 and store the result in tsmat small_dbnew:
small_dbnew=set_residuals2zero(small_cale_db,small);
// check that the residual p3m_d5_cale is now equal to 0:
prt_tsmat('level',['1990q1';'2006q4'],list('small_dbnew'),'p3m_d5_cale');

endfunction