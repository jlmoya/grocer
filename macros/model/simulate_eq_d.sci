function s=simulate_eq_d()

global GROCERDIR;
// load the model small:
load(GROCERDIR+'data\small.dat')
// load the database small_db:
load(GROCERDIR+'data\small_db.dat')
// simulate the 'td_p3m_d1' equation of model small on the period '1981q1' to
// '2006q4', with variable td_p3m_d1 as an endogenous variable
s=simulate_eq(small,small_db,'td_p3m_d1','td_p3m_d1','1981q1','2006q4')
s_db=s('simulation results');
// display the percentage error of the simulated and original database for variable
// td_p3m_d1
prt_tsmat('pcer',['1981q1';'2006q4'],list('small_db','s_db'),'td_p3m_d1')

endfunction