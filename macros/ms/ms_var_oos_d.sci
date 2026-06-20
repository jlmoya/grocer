function [r,roos]=ms_var_oos_d()

global GROCERDIR;
 
load(GROCERDIR+'\data\us_revu.dat')
 
bounds('1967m4','2002m12')
 
nb_states=2
switch_var=2 // variances are switching
var_opt=3 // heteroskedastik var-cov matrix
 
r=ms_var('const',3,'100*(log(us_revu)-lagts(2,log(us_revu)))',nb_states,switch_var,var_opt,'prt=initial;final','transf=stud')
bounds('2002m12','2004m3')
 roos=ms_var_oos(r,'100*(log(us_revu)-lagts(2,log(us_revu)))')
    
endfunction
