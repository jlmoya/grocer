function [r]=probit_d()
// PURPOSE: An example of logit(),
//                        prt_reg().
//  maximum likelihood estimation
//  (data from Spector and Mazzeo, 1980)
//---------------------------------------------------
// USAGE: logit_d
//---------------------------------------------------
 
// grade variable
 
global GROCERDIR;  
load(GROCERDIR+'\data\probit_d.dat') 

bounds()
reso = ols('grade','cte','psi','tuce','gpa');
 
// results reported in Green (1997, chapter 19)
// b = [ -1.498, 0.379, 0.010, 0.464 ]
 
r = probit('grade','cte','psi','tuce','gpa');
 
 
endfunction
