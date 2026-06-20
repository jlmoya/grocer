function r=ms_reg_oos_d()
 
// demo of ms_reg_oos
global GROCERDIR;
 
load(GROCERDIR+'\data\us_revu.dat')
 
bounds('1967m4','2002m12')
 
nb_states=2
switch_var=2 // variances are switching
var_opt=3 // unrestricted var-cov matrix
 
r=ms_reg('100*(log(us_revu)-lagts(2,log(us_revu)))',['100*(lagts(1,log(us_revu))-lagts(3,log(us_revu)))';...
'100*(lagts(2,log(us_revu))-lagts(4,log(us_revu)))';'100*(lagts(3,log(us_revu))-lagts(5,log(us_revu)))'],'cte',nb_states,switch_var,var_opt,'transf=stud',...
'prt=initial;final')

bounds('2002m12','2004m3')
roos=ms_reg_oos(r,'100*(log(us_revu)-lagts(2,log(us_revu)))',['100*(lagts(1,log(us_revu))-lagts(3,log(us_revu)))';...
'100*(lagts(2,log(us_revu))-lagts(4,log(us_revu)))';'100*(lagts(3,log(us_revu))-lagts(5,log(us_revu)))'],'cte')

endfunction
