function sim_histo=simulate_d()

global GROCERDIR
// load the model small
 load(GROCERDIR+'data\small.dat')
// load the database small_db
load(GROCERDIR+'data\small_db.dat')

// simualte the small model with database small_db from 1981q1 to 2006q4, keeping
// the data from 1978q1 and using the lagged endogenous variables as starting values
sim_histo=simulate(small,small_db,'1981q1','2006q4',1,'1978q1','2006q4') 
// display the comparison of simualtion results with the original database small_db
prt_tsmat('pcer',['1990q1';'2006q4'],list('small_db','sim_histo(''simulation results'')'),['td_pib1','td_pib3'])

endfunction