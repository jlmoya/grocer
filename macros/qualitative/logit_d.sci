function [r]=logit_d()
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
reso = ols('grade','const','psi','tuce','gpa');
timer();
// results reported in Green (1997, chapter 19)
// b = [ -1.498, 0.379, 0.010, 0.464 ]
 
 
r = logit('grade','const','psi','tuce','gpa');
// results reported in James LeSage book "Applied Econometrics using MATLAB" (p.223):
// b = [  - 13.021347  2.3786877  .0951577  2.8261126 ]
endfunction
