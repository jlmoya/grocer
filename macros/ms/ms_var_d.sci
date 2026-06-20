function r=ms_var_d()
 
global GROCERDIR;
 
// demo of ms_var
 
load(GROCERDIR+'\data\us_revu.dat')
 
bounds('1967m4','2004m2')
 
nb_states=2
switch_var=2 // variances are switching
var_opt=3 // heteroskedastik var-cov matrix
 
r=ms_var('cte',3,'100*(log(us_revu)-lagts(2,log(us_revu)))',nb_states,switch_var,var_opt,'prt=initial;final','transf=stud')
endfunction
