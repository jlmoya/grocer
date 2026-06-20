function [r,rf]=ms_mean_d()
 
global GROCERDIR;
 
// demo of ms_mean
 
load(GROCERDIR+'\data\anas.dat')
 
bounds('1984m2','2003m1')
 
nb_states=3
switch_var=1 // variances are not switching
var_opt=1 // heteroskedastik var-cov matrix
 
r=ms_mean(['delts(log(construc))';'delts(log(ipi))';'delts(log(helpwanted))';'delts(log(revu))'],...
nb_states,switch_var,var_opt,'datation=datation_bb','opt_func=optim')
rf=ms_forecast(r,'2003m11')
endfunction
