function msvar_irf_d()

global GROCERDIR;
load(GROCERDIR+'\data\anas.dat')
 
bounds('1984m2','2003m1')
nb_states=2;
switch_var=2;
var_opt=3;

// the most interesting case: AR coefficients are swicthing
r1=ms_var('all',2,['delts(log(ipi))' ; 'delts(log(helpwanted))' ; 'delts(log(revu))'],nb_states,switch_var,var_opt,'opt_func=optim')
resirf1=msvar_irf(r1,10)
pltmsirf1(resirf1)

// the case when only constants and variances switch 
r2=ms_var('const',2,['delts(log(ipi))' ; 'delts(log(helpwanted))' ; 'delts(log(revu))'],nb_states,switch_var,var_opt,'opt_func=optim')
resirf2=msvar_irf(r2,10)
pltmsirf1(resirf2)

// the case when only constants switch 
switch_var=1;
r3=ms_var('const',2,['delts(log(ipi))' ; 'delts(log(helpwanted))' ; 'delts(log(revu))'],nb_states,switch_var,var_opt,'opt_func=optim')
resirf3=msvar_irf(r3,10)
pltmsirf1(resirf3)

endfunction
