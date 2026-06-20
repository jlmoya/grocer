function [r1,r2]=ms_mean_oos_d()
 
global GROCERDIR;
 
// demo of ms_mean
 
load(GROCERDIR+'\data\anas.dat')
 
bounds('1984m2','2001m12')
 
nb_states=3
switch_var=1 // variances are not switching
var_opt=1 // heteroskedastik var-cov matrix
 
r1=ms_mean(['delts(log(construc))';'delts(log(ipi))';'delts(log(helpwanted))';'delts(log(revu))'],...
nb_states,switch_var,var_opt,'datation=datation_bb','opt_func=optim')

bounds('2002m1','2003m1')
r2=ms_mean_oos(r1,['delts(log(construc))';'delts(log(ipi))';'delts(log(helpwanted))';'delts(log(revu))'])

endfunction
