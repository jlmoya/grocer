function [sh_demmon,sh_p51g,sh_ls]=simul_shock_d()

global GROCERDIR
// load the model small
load(GROCERDIR+'data\small.dat')
// load the database small_db
load(GROCERDIR+'data\small_cale.dat')
small_cale_db=small_cale('simulation results')

// make a 1% shock on the world demand variable (variable demmon) with model small, database small_cale_db
// over the period 1981q1 to 2006q4, keeping historical values from 1980q1 to 1980q4
sh_demmon=simul_shock(small,small_cale_db,'1981q1','2006q4',list('demmon','pcer',1),'from=1980q1')
// make a 50K shock on the labour supply (variable tc_ls_d1) with model small, database small_cale_db
// over the period 1981q1 to 2006q4, keepping historical values from 1980q1 to 1980q4
// extract from database small_cale_db variables  td_p51g_d1, td_pib3 and td_p51g_d5:
tsmat2ts(small_cale_db,['td_p51g_d1';'td_p51g_d3';'td_pib3';'td_p51g_d5'])
// create a dummy with 1 values over the simulation period, 0 before:
post80q1=dummy(['1978q1';'2006q4'],['1980q1';'2006q4']);
// create the new variable:
sh_td_p51g_d1= td_p51g_d1+0.01*td_pib3/td_p51g_d5*post80q1;
// make a 1% of GDP shock on public investment (variable td_p51g_d1)
sh_p51g=simul_shock(small,small_cale_db,'1981q1','2006q4',...
list('td_p51g_d1','ts',sh_td_p51g_d1),'from=1980q1')    

sh_ls=simul_shock(small,small_cale_db,'1981q1','2006q4',list('tc_ls_d1','er',50),'from=1980q1')

endfunction